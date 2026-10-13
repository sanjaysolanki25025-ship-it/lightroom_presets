import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lightroom_template/core/constant/app_string.dart';

class CategoryDataSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches categories from API and populates Firestore collection `category_data`
  /// strictly without duplicates (id: docId, name: string).
  static Future<void> syncCategoryData() async {
    try {
      debugPrint('[CategoryDataSyncService] Checking category_data collection...');
      final collection = _firestore.collection(AppStrings.categoryData);

      // 1. Fetch presets from API
      final url = Uri.parse('https://sajjadit.xyz/Lr_Presets_File_Data/lr_20_24/view_presets.php');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[CategoryDataSyncService] Failed to fetch API (Status: ${response.statusCode})');
        return;
      }

      final List<dynamic> presets = jsonDecode(response.body);

      // 2. Extract unique category names
      final Set<String> uniqueCategories = {};
      for (final item in presets) {
        final name = item['category']?.toString().trim() ?? '';
        if (name.isNotEmpty) {
          uniqueCategories.add(name);
        }
      }

      debugPrint('[CategoryDataSyncService] Found ${uniqueCategories.length} unique categories from API.');

      // 3. Query existing categories in Firestore to prevent any duplicates
      final existingSnapshot = await collection.get();
      final Set<String> existingNames = existingSnapshot.docs
          .map((doc) => doc.data()['name']?.toString().trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();

      debugPrint('[CategoryDataSyncService] Found ${existingNames.length} existing categories in Firestore.');

      // 4. Batch insert only categories not yet present in Firestore
      final batch = _firestore.batch();
      int addedCount = 0;

      for (final catName in uniqueCategories) {
        if (!existingNames.contains(catName)) {
          final docRef = collection.doc();
          batch.set(docRef, {
            'id': docRef.id,
            'name': catName,
          });
          addedCount++;
        }
      }

      if (addedCount > 0) {
        await batch.commit();
        debugPrint('[CategoryDataSyncService] Successfully added $addedCount new categories to category_data!');
      } else {
        debugPrint('[CategoryDataSyncService] All categories already present. No duplicates added.');
      }
    } catch (e, stack) {
      debugPrint('[CategoryDataSyncService] Error syncing categories: $e\n$stack');
    }
  }
}
