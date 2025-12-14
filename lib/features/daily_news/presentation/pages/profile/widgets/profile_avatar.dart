import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.fallbackPhotoUrl,
    required this.onImageSelected,
  });

  final String? photoUrl;
  final String? fallbackPhotoUrl;
  final Future<void> Function(File file) onImageSelected;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _uploading = false;

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await widget.onImageSelected(File(picked.path));
    } catch (e, st) {
      debugPrint('Avatar upload failed: $e');
      debugPrint('$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avatar error: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = (widget.photoUrl ?? '').trim();
    final fallback = (widget.fallbackPhotoUrl ?? '').trim();

    ImageProvider? provider;
    if (url.isNotEmpty) {
      provider = NetworkImage(url);
    } else if (fallback.isNotEmpty) {
      provider = NetworkImage(fallback);
    }

    return GestureDetector(
      onTap: _uploading ? null : _pick,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: provider,
            child: provider == null ? const Icon(Icons.person, size: 48) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
              padding: const EdgeInsets.all(6),
              child: _uploading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
