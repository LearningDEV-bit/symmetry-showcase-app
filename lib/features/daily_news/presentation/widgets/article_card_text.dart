import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import '../language/translated_text.dart';

//para no repetir en grid y hero

class ArticleCardText extends StatelessWidget {
  const ArticleCardText({
    super.key,
    required this.article,
    required this.padding,
    required this.titleFallback,
    required this.descriptionFallback,
    required this.dateFallback,
    required this.titleMaxLines,
    required this.descriptionMaxLines,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.dateStyle,
    this.descriptionHeight,
    this.showDescription = true,
    this.showDate = true,
  });

  final ArticleEntity article;

  final EdgeInsets padding;

  final String titleFallback;
  final String descriptionFallback;
  final String dateFallback;

  final int titleMaxLines;
  final int descriptionMaxLines;

  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? dateStyle;

  final double? descriptionHeight;
  final bool showDescription;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final title = _clean(article.title);
    final desc = _clean(article.description);
    final date = _clean(article.publishedAt);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            title,
            fallback: titleFallback,
            maxLines: titleMaxLines,
            style: titleStyle,
          ),
          if (showDescription) ...[
            const SizedBox(height: 8),
            TranslatedText(
              desc,
              fallback: descriptionFallback,
              maxLines: descriptionMaxLines,
              style: descriptionHeight == null
                  ? descriptionStyle
                  : descriptionStyle?.copyWith(height: descriptionHeight),
            ),
          ],
          if (showDate) ...[
            const SizedBox(height: 10),
            Text(
              date.isEmpty ? dateFallback : date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: dateStyle,
            ),
          ],
        ],
      ),
    );
  }

  String _clean(String? v) => (v ?? '').trim();
}
