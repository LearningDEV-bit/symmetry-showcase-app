part of '../daily_news_hbb.dart';

class _PostCardVariant {
  const _PostCardVariant._({
    required this.radius,
    required this.imageHeight,
    required this.contentPadding,
    required this.titleLines,
    required this.previewLines,
    required this.shadowOpacity,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.titleStyle,
    required this.previewStyle,
  });

  static final hero = _PostCardVariant._(
    radius: 18,
    imageHeight: 180,
    contentPadding: const EdgeInsets.all(16),
    titleLines: 2,
    previewLines: 2,
    shadowOpacity: 0.08,
    shadowBlur: 20,
    shadowOffset: const Offset(0, 10),
    titleStyle: (theme) => theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    previewStyle: (theme) => theme.textTheme.bodyMedium?.copyWith(
      color: Colors.grey.shade700,
    ),
  );

  static final grid = _PostCardVariant._(
    radius: 16,
    imageHeight: 150,
    contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    titleLines: 2,
    previewLines: 4,
    shadowOpacity: 0.06,
    shadowBlur: 12,
    shadowOffset: const Offset(0, 6),
    titleStyle: (theme) => theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    previewStyle: (theme) => theme.textTheme.bodySmall?.copyWith(
      height: 1.35,
      color: Colors.grey.shade700,
    ),
  );

  final double radius;
  final double imageHeight;
  final EdgeInsets contentPadding;

  final int titleLines;
  final int previewLines;

  final double shadowOpacity;
  final double shadowBlur;
  final Offset shadowOffset;

  final TextStyle? Function(ThemeData theme) titleStyle;
  final TextStyle? Function(ThemeData theme) previewStyle;
}
