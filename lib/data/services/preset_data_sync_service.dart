import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lightroom_template/core/constant/app_string.dart';

class PresetDataSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Syncs presets from API into Firestore collection `lr_presets_data`.
  /// Only includes presets where WebP image is available in Cloudflare R2 presets_webp/.
  static Future<void> syncPresetsData() async {
    try {
      debugPrint('[PresetDataSyncService] Checking lr_presets_data collection...');
      final collection = _firestore.collection(AppStrings.lrPresetsData);

      // Check existing count to avoid duplicate writes
      final existingDocs = await collection.get();
      if (existingDocs.docs.length >= 1019) {
        debugPrint(
          '[PresetDataSyncService] lr_presets_data is already fully populated '
          '(${existingDocs.docs.length} documents present). Skipping re-sync.',
        );
        return;
      }

      final Set<String> existingImages = existingDocs.docs
          .map((doc) => doc.data()['image']?.toString() ?? '')
          .where((img) => img.isNotEmpty)
          .toSet();

      // Fetch API
      final url = Uri.parse('https://sajjadit.xyz/Lr_Presets_File_Data/lr_20_24/view_presets.php');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[PresetDataSyncService] Failed to fetch API (Status: ${response.statusCode})');
        return;
      }

      final List<dynamic> apiPresets = jsonDecode(response.body);

      // Sort numerically by ID
      apiPresets.sort((a, b) {
        final idA = int.tryParse(a['id']?.toString() ?? '') ?? 0;
        final idB = int.tryParse(b['id']?.toString() ?? '') ?? 0;
        return idA.compareTo(idB);
      });

      final random = Random();
      DateTime nextCreatedAt = DateTime.now().subtract(Duration(seconds: apiPresets.length));

      WriteBatch batch = _firestore.batch();
      int batchCount = 0;
      int totalAdded = 0;

      for (final item in apiPresets) {
        final rawImg = item['image']?.toString() ?? '';
        final filename = rawImg.split('/').last;
        final stem = filename.contains('.')
            ? filename.substring(0, filename.lastIndexOf('.'))
            : filename;

        // Skip if already in Firestore
        if (existingImages.contains(stem)) continue;

        // Verify availability in Cloudflare R2 presets_webp/ (IDs 86 to 1185)
        final presetId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
        if (presetId < 86 || presetId > 1185) {
          continue;
        }

        final docRef = collection.doc();
        final isPremium = (item['type']?.toString().trim().toLowerCase() ?? '') == 'premium';
        final coin = isPremium ? (10 + random.nextInt(41)) : 0;

        nextCreatedAt = nextCreatedAt.add(const Duration(seconds: 1));

        final data = {
          'category': item['category']?.toString().trim() ?? '',
          'coin': coin,
          'createdAt': Timestamp.fromDate(nextCreatedAt),
          'id': docRef.id,
          'image': stem,
          'rand': random.nextDouble(),
        };

        batch.set(docRef, data);
        batchCount++;
        totalAdded++;

        if (batchCount >= 400) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      debugPrint('[PresetDataSyncService] Finished preset sync. Total new added: $totalAdded');
    } catch (e, stack) {
      debugPrint('[PresetDataSyncService] Error during sync: $e\n$stack');
    }
  }
}
