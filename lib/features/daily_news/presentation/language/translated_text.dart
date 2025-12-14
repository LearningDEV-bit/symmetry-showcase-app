import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../language/language_cubit.dart';
import 'article_translator.dart';

class TranslatedText extends StatelessWidget {
  const TranslatedText(
      this.text, {
        super.key,
        required this.style,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
        this.fallback = '',
      });

  final String? text;
  final String fallback;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageCubit>().state;
    final original = (text ?? '').trim();
    final base = original.isEmpty ? fallback : original;

    if (lang == AppLang.en) {
      return Text(base, style: style, maxLines: maxLines, overflow: overflow);
    }

    return FutureBuilder<String>(
      future: ArticleTranslator.instance.translate(base, lang),
      builder: (context, snap) {
        final value = snap.data ?? base; // mientras traduce, muestra original para que no se borre todo
        return Text(value, style: style, maxLines: maxLines, overflow: overflow);
      },
    );
  }
}
