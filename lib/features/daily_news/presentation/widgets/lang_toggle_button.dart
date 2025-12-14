import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../language/language_cubit.dart';

class LangToggleButton extends StatelessWidget {
  const LangToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageCubit>();

    return TextButton(
      onPressed: () => context.read<LanguageCubit>().toggle(),
      child: Text(
        lang.label, // "EN" o "ES"
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
