import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'package:news_app_clean_architecture/core/services/auth_service.dart';
import 'package:news_app_clean_architecture/core/services/post_service.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({
    super.key,
    this.editPostId,
    this.initialTitle,
    this.initialContent,
    this.initialThumbnailUrl,
    this.initialThumbnailPath,
    this.initialCreatedAtClient,
  });

  final String? editPostId;
  final String? initialTitle;
  final String? initialContent;
  final String? initialThumbnailUrl;
  final String? initialThumbnailPath;
  final int? initialCreatedAtClient;

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  File? _image;
  bool _loading = false;

  String? _imageError;

  String? _existingThumbnailUrl;
  String? _existingThumbnailPath;

  static const int _requiredSize = 250;

  bool get _isEdit => widget.editPostId != null;

  @override
  void initState() {
    super.initState();

    _titleCtrl.text = (widget.initialTitle ?? '').trim();
    _contentCtrl.text = (widget.initialContent ?? '').trim();

    _existingThumbnailUrl = widget.initialThumbnailUrl?.trim();
    _existingThumbnailPath = widget.initialThumbnailPath?.trim();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _imageError = null);

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked == null) return;

    final file = File(picked.path);

    final sizeOk = await _isImageExactly250(file);
    if (!sizeOk) {
      setState(() {
        _image = null;
        _imageError = 'Image must be exactly 250×250 px.';
      });
      await _showInfoDialog(
        title: 'Invalid image size',
        message: 'Please upload an image that is exactly 250×250 px.',
      );
      return;
    }

    setState(() => _image = file);
  }

  Future<bool> _isImageExactly250(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return false;
      return decoded.width == _requiredSize && decoded.height == _requiredSize;
    } catch (_) {
      return false;
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) {
      await _showInfoDialog(
        title: 'Missing information',
        message: 'Please fill in title and text.',
      );
      return;
    }



    final hasExisting = (_existingThumbnailUrl != null &&
        _existingThumbnailUrl!.isNotEmpty) ||
        (_existingThumbnailPath != null && _existingThumbnailPath!.isNotEmpty);

    if (!_isEdit && _image == null) {
      await _showInfoDialog(
        title: 'Missing image',
        message: 'Please upload a 250×250 px image before publishing.',
      );
      return;
    }

    if (_isEdit && _image == null && !hasExisting) {
      await _showInfoDialog(
        title: 'Missing image',
        message: 'Please upload a 250×250 px image.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final service = PostService();

      if (_isEdit) {
        await service.updatePost(
          postId: widget.editPostId!,
          title: title,
          content: content,
          imageFile: _image,
        );
      } else {
        await service.createPost(
          title: title,
          content: content,
          imageFile: _image!,
          createdAtIso: DateTime.now().toIso8601String(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      await _showInfoDialog(
        title: _isEdit ? 'Save failed' : 'Publish failed',
        message: 'Something went wrong. Please try again.\n\n$e',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final createdAtClient = widget.initialCreatedAtClient;
    final createdDate = createdAtClient != null
        ? DateTime.fromMillisecondsSinceEpoch(createdAtClient)
        : DateTime.now();

    final createdText =
    MaterialLocalizations.of(context).formatFullDate(createdDate);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Edit' : 'Publish')),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
            onPressed: () async {
              try {
                await AuthService().signInWithGoogle();
                if (mounted) setState(() {});
              } catch (_) {
                if (!mounted) return;
                await _showInfoDialog(
                  title: 'Sign-in failed',
                  message: 'Could not sign in. Please try again.',
                );
              }
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit post' : 'Publish news'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              _isEdit ? 'Save' : 'Publish',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isEdit ? 'Created on: $createdText' : 'Created on: $createdText',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _loading ? null : _pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                    _imageError == null ? Colors.black12 : Colors.redAccent,
                  ),
                ),
                child: _buildImagePreview(),
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Image must be 250×250 px',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                if (_imageError != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _imageError!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'News title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TextField(
                controller: _contentCtrl,
                decoration: const InputDecoration(
                  hintText: 'Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_loading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(_image!, fit: BoxFit.cover),
      );
    }

    // If editing and there is an existing image, show it
    final url = (_existingThumbnailUrl ?? '').trim();
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _emptyImageHint(),
        ),
      );
    }

    return _emptyImageHint();
  }

  Widget _emptyImageHint() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 8),
          Text('Add photo'),
        ],
      ),
    );
  }
}
