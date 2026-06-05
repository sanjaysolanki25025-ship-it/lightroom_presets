part of 'feedback_bloc.dart';

abstract class FeedbackEvent {}

class SelectedFeedbackOptionEvent extends FeedbackEvent {
  final String selectedOption;

  SelectedFeedbackOptionEvent({required this.selectedOption});
}

class CheckedTermConditionEvent extends FeedbackEvent {
  final bool isChecked;

  CheckedTermConditionEvent({required this.isChecked});
}

class SelectedUploadImageEvent extends FeedbackEvent {}

class RemoveReferenceImageEvent extends FeedbackEvent {}

class SubmitFeedbackEvent extends FeedbackEvent {
  final FeedbackModel model;

  SubmitFeedbackEvent({required this.model});
}

