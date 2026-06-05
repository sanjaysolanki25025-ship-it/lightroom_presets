import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/models/failure_model.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/data/models/paged_presents_model.dart';

class HomeRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  /// Returns a PagedPresents so caller receives mapped models plus pagination info.
  Future<Either<FailureModel, PagedPresents>> fetchPresentWithPagination({
    String? category,
    int limit = 2,
    DocumentSnapshot? lastDoc,
    double? randomStart,
  }) async {
    try {
      Query<Map<String, dynamic>> query = fireStore.collection(AppStrings.lrPresets);

      /// CATEGORY FILTER
      if (category != null && category.isNotEmpty) {
        query = query.where("categories", arrayContains: category);
      }

      /// RANDOM START + PAGINATION
      if (randomStart != null && lastDoc == null) {
        query = query.orderBy("rand").where("rand", isGreaterThanOrEqualTo: randomStart);
      } else {
        query = query.orderBy("rand");
      }

      // query = query.orderBy("createdAt", descending: true);
      query = query.limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query
          .get(const GetOptions(source: Source.server))
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException("slow internet"),
          );

      if (snapshot.docs.isEmpty && randomStart != null) {
        return fetchPresentWithPagination(category: category, limit: limit);
      }

      final templates = snapshot.docs
          .map((doc) => LrPresetModel.fromMap(doc.data()).copyWith(id: doc.id))
          .toList();

      final last = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final hasMore = snapshot.docs.length == limit;

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
