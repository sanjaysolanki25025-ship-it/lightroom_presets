
class CategoryModel {
  final String? id;
  final String name;

  CategoryModel({this.id, required this.name});

  CategoryModel copyWith({String? id, String? name}) {
    return CategoryModel(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CategoryModel(id: docId ?? map['id'], name: map['name'] ?? '');
  }
}
