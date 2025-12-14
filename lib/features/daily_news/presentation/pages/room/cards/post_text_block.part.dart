part of '../daily_news_hbb.dart';

class _PostTextBlock extends StatelessWidget {
  const _PostTextBlock({
    required this.title,
    required this.preview,
    required this.date,
    required this.padding,
    required this.titleLines,
    required this.previewLines,
    required this.titleStyle,
    required this.previewStyle,
  });

  final String title;
  final String preview;
  final DateTime? date;

  final EdgeInsets padding;
  final int titleLines;
  final int previewLines;

  final TextStyle? titleStyle;
  final TextStyle? previewStyle;

  @override
  Widget build(BuildContext context) {
    final safeTitle = title.trim().isEmpty ? 'News without title' : title.trim();
    final safePreview = preview.trim().isEmpty ? 'No description.' : preview.trim();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            safeTitle,
            maxLines: titleLines,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
          const SizedBox(height: 6),
          Text(
            safePreview,
            maxLines: previewLines,
            overflow: TextOverflow.ellipsis,
            style: previewStyle,
          ),
          const SizedBox(height: 10),
          _PostDate(date: date),
        ],
      ),
    );
  }
}
