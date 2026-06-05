import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return LrPresetModel(
      categories: List<String>.from(map['categories'] ?? []),
      coin: (map['coin'] ?? 0) as int,
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : Timestamp.now(),
      date: map['date']?.toString() ?? '',
      id: map['id']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
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