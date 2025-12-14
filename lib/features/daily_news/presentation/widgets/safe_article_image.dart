import 'package:flutter/material.dart';

class SafeArticleImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double borderRadius;

  const SafeArticleImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.borderRadius = 0,
  });

  bool get _isValidUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return false;
    return imageUrl!.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(borderRadius),
      ),
      child: Image.network(
        imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(
        Icons.access_time,
        size: 32,
        color: Colors.grey,
      ),
    );
  }
}
