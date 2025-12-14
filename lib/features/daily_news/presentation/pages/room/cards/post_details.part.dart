part of '../daily_news_hbb.dart';

class _PostDetails extends StatelessWidget {
  const _PostDetails({required this.post});

  final UserPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = (post.imageUrl ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        _PostDate(date: post.createdAt),
        const SizedBox(height: 10),
        if (hasImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _PostImage(
              url: post.imageUrl,
              height: 210,
              radius: 16,
              fullRadius: true,
            ),
          ),
        const SizedBox(height: 12),
        Text(
          post.content,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}
