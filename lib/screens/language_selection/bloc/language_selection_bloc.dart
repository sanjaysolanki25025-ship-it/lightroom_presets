import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/screens/language_selection/models/language_model.dart';

part 'language_selection_event.dart';
part 'language_selection_state.dart';

class LanguageSelectionBloc
    extends Bloc<LanguageSelectionEvent, LanguageSelectionState> {
  LanguageSelectionBloc() : super(LanguageSelectionState.initial()) {
    on<LanguageSelectionInitialEvent>(_onInitial);
    on<SelectLanguageEvent>(_onSelectLanguage);
    on<SearchLanguageEvent>(_onSearchLanguage);
    on<ConfirmLanguageEvent>(_onConfirmLanguage);
  }

  void _onInitial(
    LanguageSelectionInitialEvent event,
    Emitter<LanguageSelectionState> emit,
  ) {
    String currentCode =
        FlutterLocalization.instance.currentLocale?.languageCode ??
            AppPreferences().getString(AppPreferences.selectedLanguage) ??
            'en';

    emit(
      state.copyWith(
        status: LanguageSelectionStatus.loaded,
        selectedLanguageCode: currentCode,
      ),
    );
  }

  void _onSelectLanguage(
    SelectLanguageEvent event,
    Emitter<LanguageSelectionState> emit,
  ) {
    emit(state.copyWith(selectedLanguageCode: event.languageCode));
  }

  void _onSearchLanguage(
    SearchLanguageEvent event,
    Emitter<LanguageSelectionState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchQuery: '',
          filteredLanguages: state.allLanguages,
        ),
      );
      return;
    }

    final filtered = state.allLanguages.where((lang) {
      return lang.name.toLowerCase().contains(query) ||
          lang.nativeName.toLowerCase().contains(query) ||
          lang.languageCode.toLowerCase().contains(query);
    }).toList();

    emit(
      state.copyWith(
        searchQuery: query,
        filteredLanguages: filtered,
      ),
    );
  }

  Future<void> _onConfirmLanguage(
    ConfirmLanguageEvent event,
    Emitter<LanguageSelectionState> emit,
  ) async {
    emit(state.copyWith(status: LanguageSelectionStatus.loading));
    FlutterLocalization.instance.translate(state.selectedLanguageCode);
    await AppPreferences().setString(
      AppPreferences.selectedLanguage,
      state.selectedLanguageCode,
    );
    if (AppPreferences().getInt(AppPreferences.coin) == null) {
      await AppPreferences().setInt(AppPreferences.coin, 50);
    }
    await AppPreferences().setBool(AppPreferences.onboarding, true);
    emit(state.copyWith(status: LanguageSelectionStatus.success));
    event.onCompleted?.call();
  }
}
