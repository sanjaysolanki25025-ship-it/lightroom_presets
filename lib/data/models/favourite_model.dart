class FavouriteModel {
  final int? id;
  final String title;
  final String image;
  final String category;
  final String presentId;
  final String coin;

  FavouriteModel({
    this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.presentId,
    required this.coin,
  });

  FavouriteModel copyWith({
    int? id,
    String? title,
    String? image,
    String? category,
    String? presentId,
    String? coin,
  }) {
    return FavouriteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      category: category ?? this.category,
      presentId: presentId ?? this.presentId,
      coin: coin ?? this.coin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'category': category,
      'presentId': presentId,
      'coin': coin,
    };
  }

  factory FavouriteModel.fromMap(Map<String, dynamic> map) {
    return FavouriteModel(
      id: map['id'],
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      presentId: map['presentId'] ?? '',
      coin: map['coin'] ?? '',
    );
  }
}