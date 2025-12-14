import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PostGridCard extends StatelessWidget {
  const PostGridCard({
    super.key,
    required this.data,
    required this.onTap,
    this.onDelete,
    this.showDelete = false,
  });

  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = (data['title'] ?? '').toString().trim();
    final description =
    (data['content'] ?? data['description'] ?? '').toString().trim();
    final dateText = _formatPostDate(context, data);

    final thumbnailUrl = (data['thumbnailUrl'] ?? '').toString().trim();
    final thumbnailPath = (data['thumbnailPath'] ?? '').toString().trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostImage(
                    radius: _radius,
                    height: 150,
                    thumbnailUrl: thumbnailUrl,
                    thumbnailPath: thumbnailPath,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'Post without title' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description.isEmpty ? 'No description.' : description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (dateText != null)
                          Text(
                            dateText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showDelete && onDelete != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _DeleteButton(onPressed: onDelete!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatPostDate(BuildContext context, Map<String, dynamic> data) {
    final now = DateTime.now();

    DateTime? created;
    final raw = data['createdAtClient'] ?? data['createdAt'] ?? data['createdAtIso'];

    if (raw is int) created = DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) created = DateTime.tryParse(raw);

    if (created == null) return null;

    final diff = now.difference(created);
    if (!diff.isNegative) {
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
    }

    final loc = MaterialLocalizations.of(context);
    final md = loc.formatShortMonthDay(created);
    final y = (created.year == now.year) ? '' : ', ${created.year}';
    return '$md$y';
  }
}

//para mas escalabilidad en el futuro dividir el archivo

class _PostImage extends StatelessWidget {
  const _PostImage({
    required this.radius,
    required this.height,
    required this.thumbnailUrl,
    required this.thumbnailPath,
  });

  final double radius;
  final double height;
  final String thumbnailUrl;
  final String thumbnailPath;

  @override
  Widget build(BuildContext context) {
    final raw = thumbnailUrl.isNotEmpty ? thumbnailUrl : thumbnailPath;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FutureBuilder<String?>(
          future: _resolveUrl(raw),
          builder: (context, snap) {
            final url = snap.data;
            if (url == null || url.isEmpty) {
              return _placeholder();
            }

            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<String?> _resolveUrl(String raw) async {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final uri = Uri.tryParse(s);

    // Already a network URL
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return s;
    }

    // gs:// bucket url
    if (uri != null && uri.scheme == 'gs') {
      return FirebaseStorage.instance.refFromURL(s).getDownloadURL();
    }

    // treat as Storage path (e.g. "media/articles/<id>.jpg")
    if (!s.contains('://')) {
      return FirebaseStorage.instance.ref(s).getDownloadURL();
    }

    return null;
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image_outlined)),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.delete_outline, size: 20),
        ),
      ),
    );
  }
}
