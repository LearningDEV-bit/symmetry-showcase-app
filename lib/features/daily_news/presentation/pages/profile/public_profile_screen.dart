import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/core/services/profile_service.dart';
import 'widgets/post_grid_card.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({
    super.key,
    required this.uid,
  });

  final String uid;

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.72,
  );

  @override
  Widget build(BuildContext context) {
    final service = ProfileService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: service.userDocStreamById(uid),
        builder: (context, snap) {
          final data = snap.data?.data();

          final name = (data?['displayName'] ?? 'User').toString().trim();
          final avatarUrl = (data?['avatarUrl'] as String?)?.trim();
          final photoUrl = (data?['photoUrl'] as String?)?.trim();

          ImageProvider? avatar;
          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            avatar = NetworkImage(avatarUrl);
          } else if (photoUrl != null && photoUrl.isNotEmpty) {
            avatar = NetworkImage(photoUrl);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: avatar,
                      child: avatar == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isEmpty ? 'User' : name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Published articles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              StreamBuilder(
                stream: service.postsByAuthorStream(uid),
                builder: (context, postsSnap) {
                  if (postsSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = postsSnap.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return const Text(
                      'No posts yet.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: _gridDelegate,
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final d = doc.data();

                      return PostGridCard(
                        data: d,
                        onTap: () {
                          // TODO: navigate to post detail

                        },
                        showDelete: false,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
