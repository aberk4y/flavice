import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/screens/recipe_detail_screen.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/widgets/recipe_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Sayfa her odağa geldiğinde favorilerin güncellenmesi için (iOS TabBar mekaniği)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFavorites();
  }

  @override
  void activate() {
    super.activate();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final db = DatabaseHelper.instance;
    final data = await db.getFavorites();

    print("FAVORI SAYISI = ${data.length}");

    if (mounted) {
      setState(() {
        _favoriteRecipes = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // iOS Tarzı Büyük Başlıklı Navigasyon Barı
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('Favoriler'),
                  border: null,
                  backgroundColor: AppColors.background,
                ),

                // İçerik Alanı
                _favoriteRecipes.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.heart_slash,
                                size: 54,
                                color: AppColors.subText.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Henüz favori tarifiniz yok.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Beğendiğiniz tarifleri kalbe basarak ekleyin.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final recipe = _favoriteRecipes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 32,
                                  child: RecipeCard(
                                    name: recipe['name'],
                                    image: recipe['image'],
                                    description: recipe['description'],
                                    prepTime: recipe['prep_time'],
                                    servings: recipe['servings'],
                                    difficulty: recipe['difficulty'],
                                    onTap: () async {
                                      // Detay sayfasına gidip geri döndüğünde favori listesini yenile
                                      await Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              RecipeDetailScreen(
                                                recipe: recipe,
                                              ),
                                        ),
                                      );
                                      _loadFavorites();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: _favoriteRecipes.length),
                      ),
              ],
            ),
    );
  }
}
