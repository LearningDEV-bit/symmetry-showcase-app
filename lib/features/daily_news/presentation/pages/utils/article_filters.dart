import '../../../domain/entities/article.dart';

class ArticleFilters {
  const ArticleFilters._();

  static List<ArticleEntity> textValid(List<ArticleEntity> items) {
    return items.where(_hasValidText).toList(growable: false);
  }

  static List<ArticleEntity> imageProbablyValid(List<ArticleEntity> items) {
    return items.where(_hasProbablyValidImage).toList(growable: false);
  }

  static bool _hasValidText(ArticleEntity a) {
    final title = a.title?.trim() ?? '';
    final desc = a.description?.trim() ?? '';

    if (title.isEmpty) return false;
    if (title.toLowerCase().contains('[removed]')) return false;
    if (desc.isEmpty) return false;

    return true;
  }

  // “Probable” porque algunos servers devuelven HTML aunque termine en .jpg


  static bool _hasProbablyValidImage(ArticleEntity a) {
    final raw = a.urlToImage?.trim();
    if (raw == null || raw.isEmpty) return false;

    final uri = Uri.tryParse(raw);
    if (uri == null) return false;

    final schemeOk = uri.scheme == 'http' || uri.scheme == 'https';
    if (!schemeOk) return false;

    final path = uri.path.toLowerCase();
    const exts = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    final hasExt = exts.any(path.endsWith);

    final q = uri.query.toLowerCase();
    final queryLooksImage =
        q.contains('format=jpg') ||
            q.contains('format=jpeg') ||
            q.contains('format=png') ||
            q.contains('format=webp');

    return hasExt || queryLooksImage;
  }
}
