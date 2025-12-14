part of 'daily_news_hbb.dart';

class _HbbStreamView extends StatelessWidget {
  const _HbbStreamView({
    required this.title,
    required this.stream,
  });

  final String title;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return _buildScaffold(
            context,
            body: const Center(child: Icon(Icons.refresh)),
          );
        }

        if (!snap.hasData) {
          return _buildScaffold(
            context,
            body: const Center(child: CupertinoActivityIndicator()),
          );
        }

        final posts = snap.data!.docs
            .map(UserPost.fromDoc)
            .where(_isValidPost)
            .toList(growable: false);

        if (posts.isEmpty) {
          return _buildScaffold(
            context,
            body: const Center(child: Text('No posts yet')),
          );
        }

        final hero = _pickHero(posts);
        final grid = posts.where((p) => p.id != hero.id).toList(growable: false);

        return _buildScaffold(
          context,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _PostHeroCard(
                  post: hero,
                  onTap: () => _openPost(context, hero),
                ),
              ),
              SliverToBoxAdapter(
                child: _CategoryButton(
                  icon: Icons.arrow_back_rounded,
                  title: 'Back to Daily',
                  subtitle: 'Exit HBB mode',
                  onTap: () => _backToDaily(context),
                ),
              ),
              SliverPadding(
                padding: DailyNewsHbb._gridPadding,
                sliver: SliverGrid(
                  gridDelegate: DailyNewsHbb._gridDelegate,
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = grid[index];
                      return _PostGridCard(
                        post: post,
                        onTap: () => _openPost(context, post),
                      );
                    },
                    childCount: grid.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, {required Widget body}) {
    return NewsStateScaffold(
      title: title,
      leading: const LangToggleButton(),
      onBookmarksTap: () => Navigator.pushNamed(context, '/SavedArticles'),
      body: body,
      floatingActionButton: SpeedDialFab(
        onProfile: () => Navigator.pushNamed(context, '/Profile'),
        onPublish: () => Navigator.pushNamed(context, '/Publish'),
      ),
    );
  }

  static bool _isValidPost(UserPost p) {
    return p.title.trim().isNotEmpty && p.content.trim().isNotEmpty;
  }

  static UserPost _pickHero(List<UserPost> items) {
    for (final p in items) {
      final img = p.imageUrl?.trim();
      if (img != null && img.isNotEmpty) return p;
    }
    return items.first;
  }

  void _backToDaily(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(context, '/');
    }
  }

  void _openPost(BuildContext context, UserPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PostDetailsPage(post: post),
      ),
    );
  }
}
