part of 'language_selection_bloc.dart';

abstract class LanguageSelectionEvent {}

class LanguageSelectionInitialEvent extends LanguageSelectionEvent {}

class SelectLanguageEvent extends LanguageSelectionEvent {
  final String languageCode;

  SelectLanguageEvent(this.languageCode);
}

class SearchLanguageEvent extends LanguageSelectionEvent {
  final String query;

  SearchLanguageEvent(this.query);
}

class ConfirmLanguageEvent extends LanguageSelectionEvent {
  final VoidCallback? onCompleted;

  ConfirmLanguageEvent({this.onCompleted});
}
