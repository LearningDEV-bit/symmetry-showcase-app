import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import 'safe_article_image.dart';
import 'article_card_text.dart';

class GridArticleCard extends StatelessWidget {
  const GridArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final ArticleEntity article;
  final VoidCallback onTap;

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArticleImage(
                imageUrl: article.urlToImage,
                height: 150,
                borderRadius: _radius,
              ),
              ArticleCardText(
                article: article,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                titleFallback: 'News without title',
                descriptionFallback: 'No description.',
                dateFallback: 'Date not available',
                titleMaxLines: 2,
                descriptionMaxLines: 4,
                descriptionHeight: 1.35,
                titleStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                descriptionStyle: theme.textTheme.bodySmall?.copyWith(
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
    );
  }
}
