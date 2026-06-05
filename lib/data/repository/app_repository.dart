import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/helpers/db_helper.dart';
import 'package:lightroom_template/data/models/category_model.dart';
import 'package:lightroom_template/data/models/failure_model.dart';
import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:sqflite/sqflite.dart';

class AppRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final dbHelper = DbHelper();

  /// fetch category
  Future<Either<FailureModel, List<CategoryModel>>> fetchCategory() async {
    try {
      final querySnapshot = await fireStore
          .collection(AppStrings.categories)
          .get();
      final categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()).copyWith(id: doc.id))
          .toList();
      return right(categories);
    } on FirebaseException catch (e) {
      return left(FailureModel("Firebase error: ${e.message}"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }

  /// fetch category by id
  // Future<Either<FailureModel, CategoryModel>> fetchCategoryById({
  //   required String id,
  // }) async {
  //   try {
  //     final docSnapshot = await fireStore
  //         .collection(AppStrings.txtCategory)
  //         .doc(id)
  //         .get();
  //     if (docSnapshot.exists) {
  //       final category = CategoryModel.fromMap(
  //         docSnapshot.data()!,
  //       ).copyWith(id: docSnapshot.id);
  //       return right(category);
  //     } else {
  //       return left(FailureModel(AppStrings.txtNoDataFound));
  //     }
  //   } on FirebaseException catch (e) {
  //     return left(FailureModel("Firebase error: ${e.message}"));
  //   } catch (e) {
  //     return left(FailureModel("Unexpected error: $e"));
  //   }
  // }
  //
  // /// fetch language by id
  // Future<Either<FailureModel, LanguageModel>> fetchLanguageById({
  //   required String id,
  // }) async {
  //   try {
  //     final docSnapshot = await fireStore
  //         .collection(AppStrings.txtLanguage)
  //         .doc(id)
  //         .get();
  //     if (docSnapshot.exists) {
  //       final language = LanguageModel.fromMap(
  //         docSnapshot.data()!,
  //       ).copyWith(id: docSnapshot.id);
  //       return right(language);
  //     } else {
  //       return left(FailureModel(AppStrings.txtNoDataFound));
  //     }
  //   } on FirebaseException catch (e) {
  //     return left(FailureModel("Firebase error: ${e.message}"));
  //   } catch (e) {
  //     return left(FailureModel("Unexpected error: $e"));
  //   }
  // }
  //
  // /// fetch template by id
  // Future<Either<FailureModel, TemplateModel>> fetchTemplateById({
  //   required String id,
  // }) async {
  //   try {
  //     final docSnapshot = await fireStore
  //         .collection(AppStrings.txtTemplatedYT)
  //         .doc(id)
  //         .get();
  //     if (docSnapshot.exists) {
  //       final language = TemplateModel.fromMap(
  //         docSnapshot.data()!,
  //       ).copyWith(id: docSnapshot.id);
  //       return right(language);
  //     } else {
  //       return left(FailureModel(AppStrings.txtNoDataFound));
  //     }
  //   } on FirebaseException catch (e) {
  //     return left(FailureModel("Firebase error: ${e.message}"));
  //   } catch (e) {
  //     return left(FailureModel("Unexpected error: $e"));
  //   }
  // }
  //
  // /// ======= local database operations =======
  // /// add favourite prompt
  Future<Either<FailureModel, FavouriteModel>> addFavourite({
    required FavouriteModel fav,
  }) async {
    try {
      final id = await dbHelper.insertFavourite(fav);
      return right(fav.copyWith(id: id));
    } on DatabaseException catch (e) {
      return left(FailureModel("Database error: ${e.toString()}"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }


  /// remove favourite prompt
  Future<Either<FailureModel, int>> removeFavourite({
    required String presentId,
  }) async {
    try {
      final id = await dbHelper.deleteBypresentId(presentId);
      return right(id);
    } on DatabaseException catch (e) {
      return left(FailureModel("Database error: ${e.toString()}"));
    } on SocketException {
      return left(FailureModel("No Internet connection"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }

  /// Fetch all favourite prompts
  Future<Either<FailureModel, List<FavouriteModel>>> fetchFavouritePresents() async {
    try {
      final favourites = await dbHelper.getFavourites();
      return right(favourites);
    } on DatabaseException catch (e) {
      return left(FailureModel("Database error: ${e.toString()}"));
    } catch (e) {
      return left(FailureModel("Unexpected error: $e"));
    }
  }
}
