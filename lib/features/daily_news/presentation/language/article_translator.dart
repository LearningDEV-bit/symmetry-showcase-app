import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../language/language_cubit.dart';

class ArticleTranslator {
  ArticleTranslator._();

  static final ArticleTranslator instance = ArticleTranslator._();

  final _manager = OnDeviceTranslatorModelManager();

  OnDeviceTranslator? _translator;
  TranslateLanguage? _currentTarget;

  final Map<String, String> _cache = {};

  Future<String> translate(String text, AppLang to) async {
    final clean = text.trim();
    if (clean.isEmpty) return clean;


    // CON EN VUELVE AL ORIGINAL


    if (to == AppLang.en) return clean;

    final key = '${to.name}|$clean';
    final cached = _cache[key];
    if (cached != null) return cached;

    final target = _mapTarget(to);


    // Descargamos el modelo por las dudas (no imprescindible)


    final downloaded = await _manager.isModelDownloaded(target.bcpCode);
    if (!downloaded) {
      await _manager.downloadModel(target.bcpCode, isWifiRequired: false);
    }


    // Si se cambia el Target recreamos el constructor


    if (_translator == null || _currentTarget != target) {
      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: target,
      );
      _currentTarget = target;
    }

    final out = await _translator!.translateText(clean);
    _cache[key] = out;
    return out;
  }


  //Simplemente definimos cual idioma corresponde a nuestros botones


  TranslateLanguage _mapTarget(AppLang to) {
    switch (to) {
      case AppLang.es:
        return TranslateLanguage.spanish;
      case AppLang.en:
        return TranslateLanguage.english;
    }
  }

  void dispose() {
    _translator?.close();
    _translator = null;
    _currentTarget = null;
  }
}
