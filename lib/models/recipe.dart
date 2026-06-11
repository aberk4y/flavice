class Recipe {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final String
  ingredients; // Virgülle ayrılmış metin (Ör: "Domates,Biber,Yumurta")
  final String instructions; // Satırla veya numarayla ayrılmış metin
  final String image;
  final String prepTime; // Yeni Eklenen: "15 dk"
  final String servings; // Yeni Eklenen: "2 Kişilik"
  final String difficulty; // Yeni Eklenen: "Kolay"

  Recipe({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.image,
    required this.prepTime,
    required this.servings,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'image': image,
      'prep_time': prepTime,
      'servings': servings,
      'difficulty': difficulty,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
      image: map['image'] as String,
      prepTime: map['prep_time'] as String,
      servings: map['servings'] as String,
      difficulty: map['difficulty'] as String,
    );
  }
}
