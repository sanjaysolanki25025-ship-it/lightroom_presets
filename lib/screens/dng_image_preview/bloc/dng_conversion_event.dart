part of 'dng_conversion_bloc.dart';

abstract class DngConversionEvent {}

class ConvertDngEvent extends DngConversionEvent {
  final String imageUrl;
  ConvertDngEvent(this.imageUrl);
}
