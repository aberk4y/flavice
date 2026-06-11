class Category {
  final int? id;
  final String name;
  final String image;

  Category({this.id, required this.name, required this.image});

  Map<String, dynamic> toMap() {
    return {if (id != null) 'id': id, 'name': name, 'image': image};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      image: map['image'] as String,
    );
  }
}
