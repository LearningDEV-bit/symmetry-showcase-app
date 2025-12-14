import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/post/publish_screen.dart';
import 'package:news_app_clean_architecture/core/services/profile_service.dart';
import 'post_grid_card.dart';
import 'profile_avatar.dart';

class ProfileView extends StatelessWidget {
  ProfileView({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onLogout;

  final ProfileService _service = ProfileService();

  static const EdgeInsets _gridPadding = EdgeInsets.symmetric(horizontal: 0);
  static const SliverGridDelegate _gridDelegate =
  SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.72,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _service.userDocStream(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();

          final avatarUrl = (data?['avatarUrl'] as String?)?.trim();
          final fallbackUrl =
              (data?['photoUrl'] as String?)?.trim() ?? (user.photoURL ?? '');

          final displayNameFromDb = data?['displayName'] as String?;
          final displayName =
          (displayNameFromDb != null && displayNameFromDb.trim().isNotEmpty)
              ? displayNameFromDb.trim()
              : (user.displayName ?? 'User');

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          ProfileAvatar(
                            photoUrl: avatarUrl,
                            fallbackPhotoUrl: fallbackUrl,
                            onImageSelected: (file) async {
                              await _service.ensureUserDoc(user);
                              await _service.saveAvatarToStorage(file);
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Change name'),
                            onPressed: () async {
                              final ctrl =
                              TextEditingController(text: displayName);

                              final newName = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Change name'),
                                  content: TextField(
                                    controller: ctrl,
                                    decoration: const InputDecoration(
                                      hintText: 'Your name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, ctrl.text),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );

                              if (newName == null) return;

                              try {
                                await _service.updateDisplayName(newName);
                              } catch (_) {
                                if (!context.mounted) return;
                                await _showInfoDialog(
                                  context,
                                  title: 'Update failed',
                                  message:
                                  'Could not update your name. Please try again.',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Published articles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _service.myPostsStream(),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final docs = snap.data?.docs ?? const [];
                              if (docs.isEmpty) {
                                return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Empty.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: _gridPadding,
                                gridDelegate: _gridDelegate,
                                itemCount: docs.length,
                                itemBuilder: (context, i) {
                                  final doc = docs[i];
                                  final d = doc.data();

                                  final authorId =
                                  (d['authorId'] ?? '').toString().trim();
                                  final canDelete = authorId == user.uid;

                                  final title = (d['title'] ?? 'this post')
                                      .toString()
                                      .trim();

                                  return PostGridCard(
                                    data: d,
                                    onTap: () {
                                      // Solo permitir editar si es del usuario (mismo criterio que delete)
                                      if (!canDelete) return;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PublishScreen(
                                            editPostId: doc.id,
                                            initialTitle: (d['title'] ?? '').toString(),
                                            initialContent: (d['content'] ?? '').toString(),
                                            initialThumbnailUrl: (d['thumbnailUrl'] ?? '').toString(),
                                            initialThumbnailPath: (d['thumbnailPath'] ?? '').toString(),
                                            initialCreatedAtClient: d['createdAtClient'] is int
                                                ? d['createdAtClient'] as int
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    showDelete: canDelete,
                                    onDelete: canDelete
                                        ? () => _confirmDelete(
                                      context,
                                      postId: doc.id,
                                      title: title,
                                    )
                                        : null,
                                  );

                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.email ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: onLogout,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, {
        required String postId,
        required String title,
      }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text('This will permanently delete "$title".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _service.deletePost(postId);
    } catch (_) {
      if (!context.mounted) return;
      await _showInfoDialog(
        context,
        title: 'Delete failed',
        message: 'Could not delete the post. Please try again.',
      );
    }
  }

  Future<void> _showInfoDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
