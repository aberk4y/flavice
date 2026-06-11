class MenuItem {
  final int? id;
  final int recipeId;
  final int isCompleted;

  MenuItem({this.id, required this.recipeId, this.isCompleted = 0});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'recipe_id': recipeId,
      'is_completed': isCompleted,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as int?,
      recipeId: map['recipe_id'] as int,
      isCompleted: map['is_completed'] as int,
    );
  }
}
