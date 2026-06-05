part of 'dng_conversion_bloc.dart';

enum DngConversionStatus { initial, loading, success, FailureModel }

class DngConversionState {
  final DngConversionStatus status;
  final Uint8List? bytes;
  final String? error;

  DngConversionState({
    required this.status,
    this.bytes,
    this.error,
  });

  factory DngConversionState.initial() => DngConversionState(status: DngConversionStatus.initial);

  DngConversionState copyWith({
    DngConversionStatus? status,
    Uint8List? bytes,
    String? error,
  }) {
    return DngConversionState(
      status: status ?? this.status,
      bytes: bytes ?? this.bytes,
      error: error ?? this.error,
    );
  }
}
