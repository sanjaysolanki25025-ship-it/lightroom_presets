
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lightroom_template/data/models/failure_model.dart';

import '../../../core/constant/app_string.dart';
import '../../../data/models/other_app_model.dart';

class OtherAppRepository {
  final FirebaseFirestore fireStore;

  OtherAppRepository({FirebaseFirestore? fireStore})
    : fireStore = fireStore ?? FirebaseFirestore.instance;

  Future<Either<FailureModel, List<OtherAppModel>>> fetchOtherApps() async {
    try {
      final snapshot = await fireStore
          .collection(AppStrings.apps)
          .get();

      final apps = await Future.wait(
        snapshot.docs.map((doc) async {
          final app = OtherAppModel.fromJson(doc.data());

          if (app.appLink.isEmpty) {
            return app;
          }

          if (app.appName.isNotEmpty && app.appLogo.isNotEmpty) {
            return app;
          }
          return app;
        }),
      );

      return right(apps);
    } on FirebaseException catch (e) {
      return left(FailureModel("Firebase error: ${e.message}"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }
}
