part of 'language_selection_bloc.dart';

enum LanguageSelectionStatus { initial, loading, loaded, success }

class LanguageSelectionState {
  final LanguageSelectionStatus status;
  final List<LanguageModel> allLanguages;
  final List<LanguageModel> filteredLanguages;
  final String selectedLanguageCode;
  final String searchQuery;

  LanguageSelectionState({
    required this.status,
    required this.allLanguages,
    required this.filteredLanguages,
    required this.selectedLanguageCode,
    required this.searchQuery,
  });

  factory LanguageSelectionState.initial() {
    return LanguageSelectionState(
      status: LanguageSelectionStatus.initial,
      allLanguages: LanguageModel.supportedLanguages,
      filteredLanguages: LanguageModel.supportedLanguages,
      selectedLanguageCode: 'en',
      searchQuery: '',
    );
  }

  LanguageSelectionState copyWith({
    LanguageSelectionStatus? status,
    List<LanguageModel>? allLanguages,
    List<LanguageModel>? filteredLanguages,
    String? selectedLanguageCode,
    String? searchQuery,
  }) {
    return LanguageSelectionState(
      status: status ?? this.status,
      allLanguages: allLanguages ?? this.allLanguages,
      filteredLanguages: filteredLanguages ?? this.filteredLanguages,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
