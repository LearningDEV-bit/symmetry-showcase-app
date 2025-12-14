import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';


import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/profile/profile_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/post/publish_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/room/daily_news_hbb.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_read/article_read_page.dart';


class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/DailyNews':
        return _materialRoute(const DailyNews());

      case '/News':

      case '/DailyNewsHBB':
        return _materialRoute(const DailyNewsHbb());

      case '/ArticleRead':
        return _materialRoute(
          ArticleReadPage(article: settings.arguments as ArticleEntity),
        );

      case '/Profile':
        return _materialRoute(const ProfileScreen());

      case '/Publish':
        return _materialRoute(const PublishScreen());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
