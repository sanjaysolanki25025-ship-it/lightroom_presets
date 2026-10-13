import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightroom_template/core/constant/app_string.dart';

class LrPresetModel {
  final List<String> categories;
  final int coin;
  final Timestamp createdAt;
  final String date;
  final String id;
  final String image;
  final String title;
  final double rand;
  final bool isFavourite;

  String get category => categories.isNotEmpty ? categories.first : '';

  String get webpImageName {
    final clean = image.trim();
    if (clean.isEmpty) return '';
    return clean.endsWith('.webp') ? clean : '$clean.webp';
  }

  String get fullImageUrl {
    final clean = image.trim();
    if (clean.isEmpty) return '';
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean.endsWith('.webp') ? clean : '$clean.webp';
    }
    return "${AppStrings.imageUrl}$webpImageName";
  }

  String get dngFileName {
    final clean = image.trim();
    if (clean.isEmpty) return '';
    final nameWithoutExt = clean.contains('.')
        ? clean.substring(0, clean.lastIndexOf('.'))
        : clean;
    return '$nameWithoutExt.dng';
  }

  String get fullDngUrl {
    final clean = image.trim();
    if (clean.isEmpty) return '';
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      final nameWithoutExt = clean.contains('.')
          ? clean.substring(0, clean.lastIndexOf('.'))
          : clean;
      return '$nameWithoutExt.dng';
    }
    return "${AppStrings.dngUrl}$dngFileName";
  }

  LrPresetModel({
    required this.categories,
    required this.coin,
    required this.createdAt,
    required this.date,
    required this.id,
    required this.image,
    required this.title,
    double? rand,
    this.isFavourite = false,
  }) : rand = rand ?? Random().nextDouble();

  factory LrPresetModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedCategories = [];
    if (map['categories'] is List) {
      parsedCategories = List<String>.from(map['categories']);
    } else if (map['category'] != null && map['category'].toString().trim().isNotEmpty) {
      parsedCategories = [map['category'].toString().trim()];
    }

    final catString = map['category']?.toString().trim() ?? '';
    final rawTitle = map['title']?.toString().trim() ?? '';
    final finalTitle = rawTitle.isNotEmpty
        ? rawTitle
        : (catString.isNotEmpty ? catString : (parsedCategories.isNotEmpty ? parsedCategories.first : ''));

    return LrPresetModel(
      categories: parsedCategories,
      coin: (map['coin'] ?? 0) as int,
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : Timestamp.now(),
      date: map['date']?.toString() ?? '',
      id: map['id']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      title: finalTitle,
      rand: (map['rand'] is num)
          ? (map['rand'] as num).toDouble()
          : Random().nextDouble(),
      isFavourite: map['isFavourite'] ?? false,
    );
  }

  factory LrPresetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LrPresetModel.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'categories': categories,
      'coin': coin,
      'createdAt': createdAt,
      'date': date,
      'id': id,
      'image': image,
      'title': title,
      'rand': rand,
      'isFavourite': isFavourite,
    };
  }

  LrPresetModel copyWith({
    List<String>? categories,
    int? coin,
    Timestamp? createdAt,
    String? date,
    String? id,
    String? image,
    String? title,
    double? rand,
    bool? isFavourite,
  }) {
    return LrPresetModel(
      categories: categories ?? this.categories,
      coin: coin ?? this.coin,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      rand: rand ?? this.rand,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}