class LanguageModel {
  final String languageCode;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageModel({
    required this.languageCode,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(
      languageCode: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageModel(
      languageCode: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    LanguageModel(
      languageCode: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
    LanguageModel(
      languageCode: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    LanguageModel(
      languageCode: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    LanguageModel(
      languageCode: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    LanguageModel(
      languageCode: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
    ),
    LanguageModel(
      languageCode: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      flag: '🇰🇷',
    ),
    LanguageModel(
      languageCode: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      flag: '🇵🇹',
    ),
    LanguageModel(
      languageCode: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      flag: '🇹🇷',
    ),
  ];
}
