part of '../daily_news_hbb.dart';

class _PostHeroCard extends StatelessWidget {
  const _PostHeroCard({
    required this.post,
    required this.onTap,
  });

  final UserPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _PostCard(
        post: post,
        onTap: onTap,
        variant: _PostCardVariant.hero,
      ),
    );
  }
}

class _PostGridCard extends StatelessWidget {
  const _PostGridCard({
    required this.post,
    required this.onTap,
  });

  final UserPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PostCard(
      post: post,
      onTap: onTap,
      variant: _PostCardVariant.grid,
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onTap,
    required this.variant,
  });

  final UserPost post;
  final VoidCallback onTap;
  final _PostCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final hasImage = (post.imageUrl ?? '').trim().isNotEmpty;
    final theme = Theme.of(context);

    return _CardSurface(
      radius: variant.radius,
      shadowOpacity: variant.shadowOpacity,
      shadowBlur: variant.shadowBlur,
      shadowOffset: variant.shadowOffset,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostImage(
            url: hasImage ? post.imageUrl : null,
            height: variant.imageHeight,
            radius: variant.radius,
          ),
          _PostTextBlock(
            title: post.title,
            preview: post.content,
            date: post.createdAt,
            padding: variant.contentPadding,
            titleLines: variant.titleLines,
            previewLines: variant.previewLines,
            titleStyle: variant.titleStyle(theme),
            previewStyle: variant.previewStyle(theme),
          ),
        ],
      ),
    );
  }
}
