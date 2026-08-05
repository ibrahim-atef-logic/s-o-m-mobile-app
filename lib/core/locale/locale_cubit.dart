import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_repository.dart';

/// Holds the active [Locale] and persists changes.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._repository) : super(_repository.read());

  final LocaleRepository _repository;

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    await _repository.write(locale);
    emit(locale);
  }

  Future<void> setLanguageCode(String code) => setLocale(Locale(code));
}
