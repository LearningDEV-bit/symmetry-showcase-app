import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLang { en, es }

class LanguageCubit extends Cubit<AppLang> {
  LanguageCubit() : super(AppLang.en);

  void toggle() {
    emit(state == AppLang.en ? AppLang.es : AppLang.en);
  }

  String get label => state == AppLang.en ? 'EN' : 'ES';
}
