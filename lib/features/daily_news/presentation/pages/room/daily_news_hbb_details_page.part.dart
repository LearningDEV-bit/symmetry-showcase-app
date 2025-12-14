part of 'daily_news_hbb.dart';

class _PostDetailsPage extends StatelessWidget {
  const _PostDetailsPage({required this.post});

  final UserPost post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
        ),
        title: const Text('Post details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: _PostDetails(post: post),
        ),
      ),
    );
  }
}
