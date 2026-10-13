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
      final collection = fireStore.collection(AppStrings.lrPresetsData);
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

      final trimmedCategory = category?.trim();
      final isAll = trimmedCategory == null || trimmedCategory.isEmpty || trimmedCategory.toLowerCase() == 'all';
      final isPremium = trimmedCategory?.toLowerCase() == 'premium';
      final isTrending = trimmedCategory?.toLowerCase() == 'trending';

      if (isPremium) {
        Query<Map<String, dynamic>> query = collection
            .where("coin", isGreaterThan: 0)
            .limit(limit);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snap = await query
            .get()
            .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException("slow internet"));

        docs = snap.docs;
      } else if (isTrending) {
        Query<Map<String, dynamic>> query = collection
            .orderBy("createdAt", descending: true)
            .limit(limit);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snap = await query
            .get()
            .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException("slow internet"));

        docs = snap.docs;
      } else if (!isAll) {
        // Query by exact category name (e.g. 'Moody', 'Sky Colour', etc.)
        // IMPORTANT: DO NOT add .orderBy("rand") here!
        // In Firestore, combining .where("category", isEqualTo: ...) with .orderBy("rand")
        // strictly requires a composite index on (category, rand). Without it, Firestore
        // throws a failed-precondition exception and fails to load any data.
        Query<Map<String, dynamic>> query = collection
            .where("category", isEqualTo: trimmedCategory)
            .limit(limit);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snap = await query
            .get()
            .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException("slow internet"));

        docs = snap.docs;
      } else {
        // "All" - no category filter
        if (randomStart != null && lastDoc == null) {
          final firstSnap = await collection
              .orderBy("rand")
              .where("rand", isGreaterThanOrEqualTo: randomStart)
              .limit(limit)
              .get()
              .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException("slow internet"));

          docs.addAll(firstSnap.docs);

          if (docs.length < limit) {
            final remaining = limit - docs.length;

            final secondSnap = await collection
                .orderBy("rand")
                .where("rand", isGreaterThanOrEqualTo: 0)
                .limit(remaining)
                .get()
                .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException("slow internet"));

            docs.addAll(secondSnap.docs);
          }
        } else {
          Query<Map<String, dynamic>> query = collection.orderBy("rand").limit(limit);

          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          }

          final snap = await query
              .get()
              .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException("slow internet"));

          docs = snap.docs;
        }
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
