// feedback_state.dart
part of 'feedback_bloc.dart';

enum FeedbackStatus { initial, submitLoading, submitLoaded, submitError, error }

class FeedbackState {
  final FeedbackStatus? status;
  final String? errorMessage;
  final String? selectedOption;
  final bool? isChecked;
  final File? imageFile;

  const FeedbackState({
    this.status,
    this.errorMessage,
    this.selectedOption,
    this.isChecked,
    this.imageFile,
  });

  factory FeedbackState.initial() {
    return FeedbackState(
      status: FeedbackStatus.initial,
      errorMessage: '',
      selectedOption: AppStrings.txtFeatureIssue,
      isChecked: false,
      imageFile: null,
    );
  }

  FeedbackState copyWith({
    FeedbackStatus? status,
    String? errorMessage,
    String? selectedOption,
    bool? isChecked,
    File? imageFile,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedOption: selectedOption ?? this.selectedOption,
      isChecked: isChecked ?? this.isChecked,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
