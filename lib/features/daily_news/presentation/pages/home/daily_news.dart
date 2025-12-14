import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/grid_article_card.dart';
import '../../widgets/hero_article_card.dart';
import '../../widgets/news_state_scaffold.dart';
import '../../widgets/lang_toggle_button.dart';
import '../../widgets/speed_dial_fab.dart';

part 'daily_news_content.part.dart';
part 'daily_news_category_button.part.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  static const String _title = 'Daily News';

  static const EdgeInsets _gridPadding = EdgeInsets.symmetric(horizontal: 16);
  static const SliverGridDelegate _gridDelegate =
  SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.72,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return NewsStateScaffold(
            title: _title,
            leading: const LangToggleButton(),
            onBookmarksTap: () => _openSaved(context),
            body: const Center(child: CupertinoActivityIndicator()),
            floatingActionButton: SpeedDialFab(
              onProfile: () => Navigator.pushNamed(context, '/Profile'),
              onPublish: () => Navigator.pushNamed(context, '/Publish'),
            ),
          );
        }

        if (state is RemoteArticlesError) {
          return NewsStateScaffold(
            title: _title,
            leading: const LangToggleButton(),
            onBookmarksTap: () => _openSaved(context),
            body: const Center(child: Icon(Icons.refresh)),
            floatingActionButton: SpeedDialFab(
              onProfile: () => Navigator.pushNamed(context, '/Profile'),
              onPublish: () => Navigator.pushNamed(context, '/Publish'),
            ),
          );
        }

        if (state is RemoteArticlesDone) {
          final articles = state.articles ?? const <ArticleEntity>[];
          return _ArticlesContent(
            title: _title,
            articles: articles,
            onOpenSaved: () => _openSaved(context),
            onOpenArticle: (a) => _openDetails(context, a),
            onOpenHbb: () => Navigator.pushNamed(context, '/DailyNewsHBB'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _openDetails(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _openSaved(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
