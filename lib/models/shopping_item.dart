class ShoppingItem {
  final int? id;
  final String ingredientName;
  final int
  isCompleted; // SQLite booleans desteklemediği için 0 (false) veya 1 (true)

  ShoppingItem({this.id, required this.ingredientName, this.isCompleted = 0});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ingredient_name': ingredientName,
      'is_completed': isCompleted,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      ingredientName: map['ingredient_name'] as String,
      isCompleted: map['is_completed'] as int,
    );
  }
}
