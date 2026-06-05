class AppValidations {
  /// empty validation
  static String? validateNotEmpty({
    required String inputValue,
    required String errorMessage,
  }) {
    if (inputValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// email validation
  static String? validateEmail({
    required String inputValue,
    required String errorMessage,
  }) {
    if (inputValue.trim().isEmpty) {
      return errorMessage;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(inputValue.trim())) {
      return "Enter valid email";
    }
    return null;
  }
}
