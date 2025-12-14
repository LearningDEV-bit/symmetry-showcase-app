part of 'daily_news_hbb.dart';


//Aca esta el “objeto” que representa un post


class UserPost {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? authorId;
  final DateTime? createdAt;

  const UserPost({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.authorId,
    this.createdAt,
  });

  factory UserPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};

    DateTime? created;
    final raw = data['createdAtClient'] ?? data['createdAt'] ?? data['createdAtServer'];
    if (raw is Timestamp) created = raw.toDate();
    if (raw is int) created = DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) created = DateTime.tryParse(raw);

    final rawImage = (data['thumbnailPath'] ??
        data['thumbnailUrl'] ??
        data['imageUrl'] ??       // estaba con base64 lo dejo por post viejos
        data['imagePath'])        // y lo mismo si guarde paths con otro nombre
        ?.toString();


    return UserPost(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      imageUrl: rawImage,
      authorId: data['authorId']?.toString(),
      createdAt: created,
    );
  }
}
