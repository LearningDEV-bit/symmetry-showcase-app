import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class PostService {
  PostService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  static const String _storageFolder = 'media/articles';
  static const int _thumbSize = 250;
  static const int _jpgQuality = 80;

  Future<void> createPost({
    required String title,
    required String content,
    required File imageFile,
    String? createdAtIso,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    final uid = user.uid;

    final userSnapshot = await _db.collection('users').doc(uid).get();
    final userData = userSnapshot.data();

    final authorName = _resolveAuthorName(
      profileDisplayName: userData?['displayName'],
      authDisplayName: user.displayName,
    );

    final authorAvatarUrl = _resolveAuthorAvatarUrl(
      profileAvatarUrl: userData?['avatarUrl'],
      profilePhotoUrl: userData?['photoUrl'],
      authPhotoUrl: user.photoURL,
    );

    final docRef = _db.collection('posts').doc();
    final postId = docRef.id;

    final thumbnailPath = await _uploadThumbnail(
      postId: postId,
      imageFile: imageFile,
    );

    await docRef.set({
      'authorId': uid,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,

      'title': title.trim(),
      'content': content.trim(),

      'thumbnailPath': thumbnailPath,

      'createdAtIso': createdAtIso,
      'createdAtClient': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }



  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    final docRef = _db.collection('posts').doc(postId);
    final snap = await docRef.get();
    final data = snap.data();
    if (data == null) throw StateError('Post not found');

    final authorId = (data['authorId'] ?? '').toString();
    if (authorId != user.uid) {
      throw StateError('Not allowed');
    }


    var thumbnailPath = (data['thumbnailPath'] ?? '').toString().trim();


    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw const FormatException('Invalid image');

      final thumb = (decoded.width == _thumbSize && decoded.height == _thumbSize)
          ? decoded
          : img.copyResizeCropSquare(decoded, size: _thumbSize);

      final jpg = img.encodeJpg(thumb, quality: _jpgQuality);
      final dataBytes = Uint8List.fromList(jpg);

      final ref = _storage.ref('$_storageFolder/$postId.jpg');
      await ref.putData(
        dataBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=86400',
        ),
      );
      thumbnailPath = ref.fullPath;
    }

    await docRef.update({
      'title': title.trim(),
      'content': content.trim(),
      'thumbnailPath': thumbnailPath,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtClient': DateTime.now().millisecondsSinceEpoch,
    });
  }


  Future<String> _uploadThumbnail({
    required String postId,
    required File imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Invalid image');

    final thumb = (decoded.width == _thumbSize && decoded.height == _thumbSize)
        ? decoded
        : img.copyResizeCropSquare(decoded, size: _thumbSize);

    final jpg = img.encodeJpg(thumb, quality: _jpgQuality);
    final data = Uint8List.fromList(jpg);

    final ref = _storage.ref('$_storageFolder/$postId.jpg');
    await ref.putData(
      data,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=86400',
      ),
    );

    return ref.fullPath; // "media/articles/<postId>.jpg"
  }

  static String _resolveAuthorName({
    required Object? profileDisplayName,
    required String? authDisplayName,
  }) {
    final fromProfile = _asTrimmedStringOrNull(profileDisplayName);
    if (fromProfile != null) return fromProfile;

    final fromAuth = (authDisplayName ?? '').trim();
    return fromAuth.isEmpty ? 'User' : fromAuth;
  }

  static String? _resolveAuthorAvatarUrl({
    required Object? profileAvatarUrl,
    required Object? profilePhotoUrl,
    required String? authPhotoUrl,
  }) {
    final a = _asTrimmedStringOrNull(profileAvatarUrl);
    if (a != null) return a;

    final p = _asTrimmedStringOrNull(profilePhotoUrl);
    if (p != null) return p;

    final auth = (authPhotoUrl ?? '').trim();
    return auth.isEmpty ? null : auth;
  }

  static String? _asTrimmedStringOrNull(Object? value) {
    final str = value is String ? value.trim() : null;
    return (str == null || str.isEmpty) ? null : str;
  }
}
