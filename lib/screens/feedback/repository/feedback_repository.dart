import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/models/failure_model.dart';
import 'package:lightroom_template/data/models/feedback_model.dart';

class FeedbackRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<Either<FailureModel, Unit>> submitFeedback({
    required FeedbackModel model,
    File? referenceImageFile,
  }) async {
    try {
      final docRef = fireStore.collection(AppStrings.feedback).doc();
      final docId = docRef.id;

      String? imageUrl;

      if (referenceImageFile != null && referenceImageFile.path.isNotEmpty) {
        final storageRef = firebaseStorage.ref().child('review/$docId.jpg');

        await storageRef
            .putFile(referenceImageFile)
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => throw TimeoutException("slow internet"),
            );

        imageUrl = await storageRef.getDownloadURL().timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw TimeoutException("slow internet"),
        );
      }

      final updatedModel = model.copyWith(id: docId, referenceImage: imageUrl);

      await docRef
          .set(updatedModel.toMap())
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException("slow internet"),
          );

      return right(unit);
    } on TimeoutException {
      return left(FailureModel(AppStrings.txtNoInternetConnection));
    } on FirebaseException catch (e) {
      return left(FailureModel("Firebase error: ${e.message}"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }
}
