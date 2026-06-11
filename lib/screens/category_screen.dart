import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/widgets/recipe_card.dart';
import 'package:mealio/screens/recipe_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> _categoryRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryRecipes();
  }

  Future<void> _loadCategoryRecipes() async {
    final db = DatabaseHelper.instance;
    final data = await db.getRecipesByCategory(widget.categoryId);

    if (mounted) {
      setState(() {
        _categoryRecipes = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      // iOS yerel geri dönüş butonu barındıran navigasyon barı
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.categoryName),
        previousPageTitle: 'Keşfet', // iOS tarzı sol üst geri metni
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : _categoryRecipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.tray,
                      size: 48,
                      color: AppColors.subText.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bu kategoride henüz tarif yok.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.subText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                physics:
                    const BouncingScrollPhysics(), // Orijinal iOS ivmeli kaydırma mekaniği
                itemCount: _categoryRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = _categoryRecipes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Kartların ekrana tam oturması için genişliğini ayarlayarak çağırıyoruz
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          child: RecipeCard(
                            name: recipe['name'],
                            image: recipe['image'],
                            description: recipe['description'],
                            prepTime: recipe['prep_time'],
                            servings: recipe['servings'],
                            difficulty: recipe['difficulty'],
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipe: recipe),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
