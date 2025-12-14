import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import 'safe_article_image.dart';
import 'article_card_text.dart';

class HeroArticleCard extends StatelessWidget {
  const HeroArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final ArticleEntity article;
  final VoidCallback onTap;

  static const _radius = 18.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArticleImage(
                  imageUrl: article.urlToImage,
                  height: 180,
                  borderRadius: _radius,
                ),
                ArticleCardText(
                  article: article,
                  padding: const EdgeInsets.all(16),
                  titleFallback: 'News without title',
                  descriptionFallback:
                  'No description is available for this news item..',
                  dateFallback: 'Date not available',
                  titleMaxLines: 2,
                  descriptionMaxLines: 2,
                  titleStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  descriptionStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  dateStyle: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
