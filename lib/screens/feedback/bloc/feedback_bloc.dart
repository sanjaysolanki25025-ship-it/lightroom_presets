import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lightroom_template/screens/feedback/repository/feedback_repository.dart';

import '../../../core/constant/app_string.dart';
import '../../../data/models/feedback_model.dart';

part 'feedback_event.dart';

part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc() : super(FeedbackState.initial()) {
    on<SelectedFeedbackOptionEvent>(_selectedFeedbackOptionEvent);
    on<CheckedTermConditionEvent>(_checkedTermConditionEvent);
    on<SelectedUploadImageEvent>(_selectedUploadImageEvent);
    on<RemoveReferenceImageEvent>(_removeReferenceImageEvent);
    on<SubmitFeedbackEvent>(_submitFeedbackEvent);
  }

  File? imageFile;
  final ImagePicker picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  TextEditingController facingIssueController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  FeedbackRepository feedbackCenterRepository = FeedbackRepository();

  final List<String> issueStrings = [
    AppStrings.txtFeedbackAndIssue,
    AppStrings.txtContentIssue,
    AppStrings.txtFeatureIssue,
  ];

  /// selected feedback option event
  FutureOr<void> _selectedFeedbackOptionEvent(
    SelectedFeedbackOptionEvent event,
    Emitter<FeedbackState> emit,
  ) {
    emit(state.copyWith(selectedOption: event.selectedOption));
  }

  /// checked term condition event
  FutureOr<void> _checkedTermConditionEvent(CheckedTermConditionEvent event, Emitter<FeedbackState> emit) {
    emit(state.copyWith(isChecked: event.isChecked, status: FeedbackStatus.initial));
  }

  /// selected upload image event
  Future<void> _selectedUploadImageEvent(SelectedUploadImageEvent event, Emitter<FeedbackState> emit) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    emit(
      state.copyWith(
        imageFile: pickedFile != null ? File(pickedFile.path) : null,
        status: FeedbackStatus.initial,
      ),
    );
  }

  /// remove reference image event
  FutureOr<void> _removeReferenceImageEvent(RemoveReferenceImageEvent event, Emitter<FeedbackState> emit) {
    emit(state.copyWith(imageFile: File(''), status: FeedbackStatus.initial));
  }

  /// submit feedback event
  Future<void> _submitFeedbackEvent(SubmitFeedbackEvent event, Emitter<FeedbackState> emit) async {
    if (state.isChecked == false) {
      emit(
        state.copyWith(status: FeedbackStatus.error, errorMessage: AppStrings.txtPleaseSelectedPrivacyPolicy),
      );
      return;
    }
    if (state.imageFile == null || state.imageFile!.path.isEmpty) {
      emit(
        state.copyWith(
          status: FeedbackStatus.error,
          errorMessage: AppStrings.txtPleaseSelectedReferenceImage,
        ),
      );
      return;
    }

    emit(state.copyWith(status: FeedbackStatus.submitLoading));
    final result = await feedbackCenterRepository.submitFeedback(
      model: event.model,
      referenceImageFile: state.imageFile,
    );
    result.match(
      (f) {
        emit(state.copyWith(status: FeedbackStatus.submitError, errorMessage: f?.message ?? 'Failed to submit'));
      },
      (r) {
        emit(state.copyWith(status: FeedbackStatus.submitLoaded));
      },
    );
  }
}
