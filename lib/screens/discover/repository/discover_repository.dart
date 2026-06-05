import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/models/failure_model.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/data/models/paged_presents_model.dart';

class DiscoverRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  /// fetch template with filter
  Future<Either<FailureModel, PagedPresents>> fetchPresentsDiscover({
    String? category,
    int limit = 6,
    DocumentSnapshot? lastDoc,
    double? randomStart,
  }) async {
    try {
      Query<Map<String, dynamic>> baseQuery = fireStore.collection(AppStrings.lrPresets);

      if (category != null && category.isNotEmpty) {
        baseQuery = baseQuery.where("categories", arrayContains: category);
      }

      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

      /// ---------------- FIRST RANDOM QUERY ----------------
      if (randomStart != null && lastDoc == null) {
        final firstSnap = await baseQuery
            .orderBy("rand")
            .where("rand", isGreaterThanOrEqualTo: randomStart)
            .limit(limit)
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 8), onTimeout: () => throw TimeoutException("slow internet"));

        docs.addAll(firstSnap.docs);

        /// ---------------- WRAP AROUND QUERY ----------------
        if (docs.length < limit) {
          final remaining = limit - docs.length;

          final secondSnap = await baseQuery
              .orderBy("rand")
              .where("rand", isGreaterThanOrEqualTo: 0)
              .limit(remaining)
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 8), onTimeout: () => throw TimeoutException("slow internet"));

          docs.addAll(secondSnap.docs);
        }
      } else {
        Query<Map<String, dynamic>> query = baseQuery.orderBy("rand").limit(limit);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snap = await query
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 8), onTimeout: () => throw TimeoutException("slow internet"));

        docs = snap.docs;
      }

      final templates = docs.map((doc) => LrPresetModel.fromMap(doc.data()).copyWith(id: doc.id)).toList();

      final last = docs.isNotEmpty ? docs.last : null;
      final hasMore = docs.length == limit;

      return right(PagedPresents(presents: templates, lastDoc: last, hasMore: hasMore));
    } on TimeoutException {
      return left(FailureModel(AppStrings.txtNoInternetConnection));
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return left(FailureModel(AppStrings.txtNoInternetConnection));
      }
      return left(FailureModel("Firebase error: ${e.message}"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }
}
