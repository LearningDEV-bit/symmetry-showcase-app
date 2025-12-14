part of 'daily_news.dart';

class _ArticlesContent extends StatelessWidget {
  const _ArticlesContent({
    required this.title,
    required this.articles,
    required this.onOpenSaved,
    required this.onOpenArticle,
    required this.onOpenHbb,
  });

  final String title;
  final List<ArticleEntity> articles;
  final VoidCallback onOpenSaved;
  final ValueChanged<ArticleEntity> onOpenArticle;
  final VoidCallback onOpenHbb;

  @override
  Widget build(BuildContext context) {
    final textValid = articles.where(_hasValidText).toList(growable: false);

    if (textValid.isEmpty) {
      return NewsStateScaffold(
        title: title,
        leading: const LangToggleButton(),
        onBookmarksTap: onOpenSaved,
        body: const Center(child: Text('No news available')),
        floatingActionButton: SpeedDialFab(
          onProfile: () => Navigator.pushNamed(context, '/Profile'),
          onPublish: () => Navigator.pushNamed(context, '/Publish'),
        ),
      );
    }

    final hero = _pickHero(textValid);
    final grid = textValid.where((a) => a != hero).toList(growable: false);

    return NewsStateScaffold(
      title: title,
      leading: const LangToggleButton(),
      onBookmarksTap: onOpenSaved,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HeroArticleCard(
              article: hero,
              onTap: () => onOpenArticle(hero),
            ),
          ),
          SliverToBoxAdapter(
            child: _CategoryButton(
              icon: Icons.bolt_rounded,
              title: 'Yellowish',
              subtitle: 'HOT (HBB)',
              onTap: onOpenHbb,
            ),
          ),
          SliverPadding(
            padding: DailyNews._gridPadding,
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = grid[index];
                  return GridArticleCard(
                    article: article,
                    onTap: () => onOpenArticle(article),
                  );
                },
                childCount: grid.length,
              ),
              gridDelegate: DailyNews._gridDelegate,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
      floatingActionButton: SpeedDialFab(
        onProfile: () => Navigator.pushNamed(context, '/Profile'),
        onPublish: () => Navigator.pushNamed(context, '/Publish'),
      ),
    );
  }

  ArticleEntity _pickHero(List<ArticleEntity> items) {
    for (final a in items) {
      if (_hasProbablyValidImage(a)) return a;
    }
    return items.first;
  }

  static bool _hasValidText(ArticleEntity a) {
    final title = a.title?.trim() ?? '';
    final desc = a.description?.trim() ?? '';

    if (title.isEmpty) return false;
    if (title.toLowerCase().contains('[removed]')) return false;
    if (desc.isEmpty) return false;

    return true;
  }

  static bool _hasProbablyValidImage(ArticleEntity a) {
    final raw = a.urlToImage?.trim();
    if (raw == null || raw.isEmpty) return false;

    final uri = Uri.tryParse(raw);
    if (uri == null) return false;

    final schemeOk = uri.scheme == 'http' || uri.scheme == 'https';
    if (!schemeOk) return false;

    return true;
  }
}
