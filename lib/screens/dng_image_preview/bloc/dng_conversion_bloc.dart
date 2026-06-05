import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:lightroom_template/core/utils/dng_cache.dart';

part 'dng_conversion_event.dart';
part 'dng_conversion_state.dart';

class DngConversionBloc extends Bloc<DngConversionEvent, DngConversionState> {
  DngConversionBloc() : super(DngConversionState.initial()) {
    on<ConvertDngEvent>(_onConvertDng);
  }

  // ─────────────────────────────────────────────
  // INTERNAL: fetch + decode
  // ─────────────────────────────────────────────

  static Future<Uint8List?> _fetchAndDecode(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List converted = await compute(_decodeDng, response.bodyBytes);
        if (converted.isNotEmpty) return converted;
      }
    } catch (e) {
      debugPrint("Error fetching/decoding DNG: $e");
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // PUBLIC: precache a URL in background
  // Called by HomeView on page change
  // ─────────────────────────────────────────────

  static Future<void> precacheDng(String imageUrl) async {
    await DngCache.instance.getOrStartLoad(
      imageUrl,
          () => _fetchAndDecode(imageUrl),
    );
  }

  // ─────────────────────────────────────────────
  // PUBLIC: evict a URL from cache
  // Called by HomeView to free memory for old pages
  // ─────────────────────────────────────────────

  static void evictDng(String imageUrl) {
    DngCache.instance.removeCache(imageUrl);
  }

  // ─────────────────────────────────────────────
  // CONVERT EVENT
  // ─────────────────────────────────────────────

  Future<void> _onConvertDng(ConvertDngEvent event, Emitter<DngConversionState> emit) async {
    // ✅ Already cached — emit instantly, 0 delay
    if (DngCache.instance.hasCache(event.imageUrl)) {
      emit(state.copyWith(
        status: DngConversionStatus.success,
        bytes: DngCache.instance.getBytes(event.imageUrl),
      ));
      return;
    }

    emit(state.copyWith(status: DngConversionStatus.loading));

    // ✅ Joins existing download if precache already started
    // No duplicate network request
    final bytes = await DngCache.instance.getOrStartLoad(
      event.imageUrl,
          () => _fetchAndDecode(event.imageUrl),
    );

    if (bytes != null && bytes.isNotEmpty) {
      emit(state.copyWith(status: DngConversionStatus.success, bytes: bytes));
    } else {
      emit(state.copyWith(
        status: DngConversionStatus.FailureModel,
        error: "Failed to load DNG",
      ));
    }
  }
}

// ─────────────────────────────────────────────
// TOP-LEVEL — required for compute()
// ─────────────────────────────────────────────

Uint8List _decodeDng(Uint8List rawBytes) {
  try {
    final img.Image? decodedImage = img.decodeImage(rawBytes);
    if (decodedImage != null) {
      return Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));
    }
  } catch (e) {
    debugPrint("Error decoding DNG: $e");
  }
  return Uint8List(0);
}