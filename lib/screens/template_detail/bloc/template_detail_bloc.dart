import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'template_detail_event.dart';

part 'template_detail_state.dart';

class TemplateDetailBloc extends Bloc<TemplateDetailEvent, TemplateDetailState> {
  static const _navigationChannel = MethodChannel('com.nebalcore.lightroom/navigation');

  TemplateDetailBloc() : super(TemplateDetailState()) {
    on<TemplateDetailLoadRewardAD>(_templateDetailLoadRewardAD);
    on<TemplateDetailStoreCoinEvent>(_templateDetailStoreCoinEvent);
    on<TemplateDetailLoadedRewardAD>(_templateDetailLoadedRewardAD);
    on<TemplateDetailPlayDinoGame>(_templateDetailPlayDinoGame);
    on<TemplateDetailDownloadImage>(_templateDetailDownloadImage);
    on<TemplateDetailUsedCoin>(_templateDetailUsedCoin);
    on<TemplateDetailCheckLightroomInstallation>(_templateDetailCheckLightroomInstallation);
    on<ResetStatus>(_resetStatus);
    on<OpenInLightroomEvent>(_openInLightroomEvent);
    on<CountOnBackPressEvent>(_countOnBackPressEvent);
  }

  FutureOr<void> _templateDetailLoadRewardAD(
    TemplateDetailLoadRewardAD event,
    Emitter<TemplateDetailState> emit,
  ) {
    emit(state.copyWith(status: TemplateDetailStatus.rewardAdLoading));
  }

  FutureOr<void> _templateDetailStoreCoinEvent(
    TemplateDetailStoreCoinEvent event,
    Emitter<TemplateDetailState> emit,
  ) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin + 2;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
  }

  FutureOr<void> _templateDetailLoadedRewardAD(
    TemplateDetailLoadedRewardAD event,
    Emitter<TemplateDetailState> emit,
  ) {
    emit(state.copyWith(status: TemplateDetailStatus.rewardAdLoaded));
  }

  FutureOr<void> _templateDetailPlayDinoGame(
    TemplateDetailPlayDinoGame event,
    Emitter<TemplateDetailState> emit,
  ) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin - 5;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
    emit(state.copyWith(status: TemplateDetailStatus.navigateToDinoGame));
  }

  Future<void> _templateDetailDownloadImage(
    TemplateDetailDownloadImage event,
    Emitter<TemplateDetailState> emit,
  ) async {
    emit(state.copyWith(status: TemplateDetailStatus.downloading));

    try {
      final response = await http.get(Uri.parse(event.url));

      if (response.statusCode != 200) {
        throw Exception('Download failed');
      }

      final bytes = response.bodyBytes;
      final rawName = event.fileName.replaceAll(' ', '_');
      final fileName = rawName.endsWith('.dng') ? rawName : '$rawName.dng';

      if (Platform.isAndroid) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);

        final bool? success = await _navigationChannel.invokeMethod('saveToDownloads', {
          'filePath': tempFile.path,
          'fileName': fileName,
        });

        if (success != true) {
          throw Exception('Failed to save to Downloads folder');
        }

        emit(
          state.copyWith(
            status: TemplateDetailStatus.downloadSuccess,
            downloadMessage: "${AppStrings.txtDownloadedTo} Download/$fileName",
          ),
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);

        emit(
          state.copyWith(
            status: TemplateDetailStatus.downloadSuccess,
            downloadMessage: "${AppStrings.txtDownloadedTo} $fileName",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplateDetailStatus.downloadFailureModel,
          downloadMessage: "${AppStrings.txtDownloadFailed} $e",
        ),
      );
    }
  }

  FutureOr<void> _templateDetailUsedCoin(TemplateDetailUsedCoin event, Emitter<TemplateDetailState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin - event.coin;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
    emit(state.copyWith(status: TemplateDetailStatus.initial));
  }

  Future<void> _templateDetailCheckLightroomInstallation(
    TemplateDetailCheckLightroomInstallation event,
    Emitter<TemplateDetailState> emit,
  ) async {
    final isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: 'com.adobe.lrmobile',
      iosUrlScheme: 'lightroom://',
    );

    if (!isInstalled) {
      emit(
        state.copyWith(
          status: TemplateDetailStatus.lightroomNotInstalled,
          downloadMessage: AppStrings.txtLightroomIsNotInstalled,
          entry: event.entry,
        ),
      );
      return;
    }

    emit(state.copyWith(status: TemplateDetailStatus.lightroomInstalled, entry: event.entry));
  }

  FutureOr<void> _resetStatus(ResetStatus event, Emitter<TemplateDetailState> emit) {
    emit(state.copyWith(status: TemplateDetailStatus.initial));
  }

  Future<void> _openInLightroomEvent(OpenInLightroomEvent event, Emitter<TemplateDetailState> emit) async {
    emit(state.copyWith(status: TemplateDetailStatus.openingInLightroom));

    try {
      final dio = Dio();

      final Directory directory = Platform.isAndroid
          ? await getTemporaryDirectory()
          : await getApplicationDocumentsDirectory();

      final rawName = event.fileName.split('.').first.replaceAll(' ', '_');
      final fileName = rawName.endsWith('.dng') ? rawName : '$rawName.dng';

      final savePath = p.join(directory.path, fileName);
      final file = File(savePath);

      // Download DNG file if not already downloaded or empty
      if (!await file.exists() || await file.length() == 0) {
        await dio.download(event.url, savePath, options: Options(responseType: ResponseType.bytes));
      }

      // Open in Lightroom
      if (Platform.isAndroid) {
        final bool? success = await _navigationChannel.invokeMethod('openInLightroom', {'filePath': savePath});
        if (success != true) {
          throw Exception("Could not open in Lightroom");
        }
      } else if (Platform.isIOS) {
        await LaunchApp.openApp(iosUrlScheme: 'lightroom://', androidPackageName: 'com.adobe.lrmobile');
      }

      emit(state.copyWith(status: TemplateDetailStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplateDetailStatus.downloadFailureModel,
          downloadMessage: "Failed to open in Lightroom: $e",
        ),
      );
    }
  }

  /// count on back press
  FutureOr<void> _countOnBackPressEvent(CountOnBackPressEvent event, Emitter<TemplateDetailState> emit) {
    final int discoverBackPress = AppPreferences().getInt(AppPreferences.onBackPress) ?? 0;
    final resultDiscoverBackPress = discoverBackPress + 1;
    AppPreferences().setInt(AppPreferences.onBackPress, resultDiscoverBackPress);
  }
}
