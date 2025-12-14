import 'package:news_app_clean_architecture/features/daily_news/presentation/language/translated_text.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/language/language_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../widgets/safe_article_image.dart';
class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),

          // ✅ Botón "Leer completo" (simple y consistente)
          _buildReadFullButton(),

          _buildArticleImage(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildReadFullButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Builder(
          builder: (context) {
            final lang = context.read<LanguageCubit>().state;
            final label = (lang == AppLang.es) ? 'Leer completo' : 'Read full';

            return TextButton.icon(
              onPressed: () {
                final a = article;
                if (a == null) return;

                Navigator.pushNamed(
                  context,
                  '/ArticleRead',
                  arguments: a,
                );
              },
              icon: const Icon(Ionicons.reader_outline, size: 18),
              label: Text(label),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildArticleTitleAndDate() {
    final title = article?.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // Traductor del Titulo


          TranslatedText(
            title,
            fallback: 'News without title',
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          // DateTime (no se traduce, pero con fallback)
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                (article?.publishedAt?.trim().isNotEmpty ?? false)
                    ? article!.publishedAt!
                    : 'Date not available',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(top: 14),
      child: SafeArticleImage(
        imageUrl: article?.urlToImage,
        height: 250,
        borderRadius: 0,
      ),
    );
  }

  Widget _buildArticleDescription() {
    final desc = (article?.description ?? '').trim();
    final content = (article?.content ?? '').trim();

    final combined = [
      if (desc.isNotEmpty) desc,
      if (content.isNotEmpty) content,
    ].join('\n\n');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: TranslatedText(
        combined,
        fallback: 'No description.',
        maxLines: null,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onFloatingActionButtonPressed(context),
        child: const Icon(Ionicons.bookmark, color: Colors.white),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    final a = article;
    if (a == null) return;

    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(a));


    // SnackBar traducible simple


    final lang = context.read<LanguageCubit>().state;
    final msg = (lang == AppLang.es)
        ? 'Saved article.'
        : 'Article saved.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(msg),
      ),
    );
  }
}
