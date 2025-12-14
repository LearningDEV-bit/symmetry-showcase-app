import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class ProfileService {
  ProfileService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  String get _currentUid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('You must log in');
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream() {
    final uid = _currentUid;
    return _userDoc(uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStreamById(String uid) {
    return _userDoc(uid).snapshots();
  }

  Future<void> ensureUserDoc(User user) async {
    await _userDoc(user.uid).set(
      {
        'displayName': _safeDisplayName(user.displayName),
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'The name cannot be empty.');
    }

    final uid = _currentUid;

    await _userDoc(uid).set(
      {
        'displayName': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await _auth.currentUser?.updateDisplayName(trimmed);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myPostsStream() {
    final uid = _currentUid;

    return _db.collection('posts').where('authorId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> postsByAuthorStream(String uid) {
    return _db.collection('posts').where('authorId', isEqualTo: uid).snapshots();
  }

  Future<void> deletePost(String postId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');

    final ref = _db.collection('posts').doc(postId);

    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data();

    final authorId = (data?['authorId'] ?? '').toString().trim();
    if (authorId.isNotEmpty && authorId != uid) {
      throw StateError('Not allowed');
    }

    final thumbPath = (data?['thumbnailPath'] ?? '').toString().trim();
    if (thumbPath.isNotEmpty) {
      try {
        await _storage.ref(thumbPath).delete();
      } catch (_) {}
    }

    await ref.delete();
  }

  Future<void> saveAvatarToStorage(
      File file, {
        int size = 250,
        int quality = 80,
      }) async {
    final uid = _currentUid;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('The image could not be read');
    }

    final squared = img.copyResizeCropSquare(decoded, size: size);
    final jpg = img.encodeJpg(squared, quality: quality);
    final data = Uint8List.fromList(jpg);

    final ref = _storage.ref('media/avatars/$uid.jpg');

    await ref.putData(
      data,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=86400',
      ),
    );

    final url = await ref.getDownloadURL();

    await _userDoc(uid).set(
      {
        'avatarUrl': url,
        'avatarUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static String _safeDisplayName(String? value) {
    final name = (value ?? '').trim();
    return name.isEmpty ? 'User' : name;
  }
}
