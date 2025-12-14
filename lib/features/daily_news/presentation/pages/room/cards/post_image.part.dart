part of '../daily_news_hbb.dart';

class _PostImage extends StatelessWidget {
  const _PostImage({
    required this.url,
    required this.height,
    required this.radius,
    this.fullRadius = false,
  });

  final String? url;
  final double height;
  final double radius;
  final bool fullRadius;

  Uint8List? _tryDecodeBase64(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final cleaned = s.contains(',') ? s.split(',').last.trim() : s;

    try {
      return base64Decode(cleaned);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveUrl(String? raw) async {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    final uri = Uri.tryParse(s);

    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return s;
    }

    if (uri != null && uri.scheme == 'gs') {
      return FirebaseStorage.instance.refFromURL(s).getDownloadURL();
    }

    if (!s.contains('://')) {
      return FirebaseStorage.instance.ref(s).getDownloadURL();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final raw = url?.trim() ?? '';
    final bytes = raw.isEmpty ? null : _tryDecodeBase64(raw);

    final br = fullRadius
        ? BorderRadius.circular(radius)
        : BorderRadius.vertical(top: Radius.circular(radius));

    return ClipRRect(
      borderRadius: br,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover)
            : FutureBuilder<String?>(
          future: _resolveUrl(url),
          builder: (context, snap) {
            final resolved = snap.data;
            final hasUrl = resolved != null && resolved.trim().isNotEmpty;

            if (!hasUrl) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.campaign_rounded)),
              );
            }

            return Image.network(
              resolved,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CupertinoActivityIndicator());
              },
            );
          },
        ),
      ),
    );
  }
}
