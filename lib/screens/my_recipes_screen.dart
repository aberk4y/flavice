import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/screens/add_recipe_screen.dart';
import 'package:mealio/screens/recipe_detail_screen.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/widgets/recipe_card.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  List<Map<String, dynamic>> _userRecipes = [];
  int _totalRecipesCount = 0;
  int _favCount = 0;
  List<Map<String, dynamic>> _favoriteRecipes = [];
  bool _isLoading = true;
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    _loadAllProfileData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAllProfileData();
  }

  Future<void> _loadAllProfileData() async {
    final db = DatabaseHelper.instance;
    final userRecipesData = await db.getUserRecipes();
    final favs = await db.getFavorites();

    if (mounted) {
      setState(() {
        _userRecipes = userRecipesData;
        _favoriteRecipes = favs;
        _totalRecipesCount = userRecipesData.length;
        _favCount = favs.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecipe(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteUserRecipe(id);
    _loadAllProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // iOS Tarzı Üst Başlık Kurgusu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Profilim',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                            letterSpacing: -1.0,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 44,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const AddRecipeScreen(),
                              ),
                            );
                            _loadAllProfileData();
                          },
                          child: const Icon(
                            CupertinoIcons.plus_circle_fill,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 1. İKİLİ ÜST İSTATİSTİK KARTI
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '$_totalRecipesCount',
                              'Toplam Tarif',
                            ),
                          ),
                          _buildDivider(),
                          Expanded(
                            child: _buildStatItem('$_favCount', 'Favoriler'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. iOS SEGMENT KONTROLÜ
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedSegment,
                        backgroundColor: CupertinoColors.systemGroupedBackground
                            .withOpacity(0.6),
                        thumbColor: AppColors.card,
                        children: const {
                          0: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.doc_text, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Tariflerim',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          1: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.heart_fill, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Favoriler',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        },
                        onValueChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              _selectedSegment = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // 3. SEÇİLİ SEKMENİN İÇERİĞİ
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedSegment == 0
                        ? _buildMyRecipesSection()
                        : _buildFavoritesSection(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 26,
      color: AppColors.divider.withOpacity(0.6),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.subText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMyRecipesSection() {
    if (_userRecipes.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.doc_text,
        title: 'Henüz kendi tarifini eklemedin.',
        subtitle: 'Sağ üstteki + butonuna basarak ilk tarifini ekle.',
      );
    }

    return ListView.builder(
      key: const ValueKey(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userRecipes.length,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemBuilder: (context, index) {
        final recipe = _userRecipes[index];

        // DEĞİŞİKLİK: Karta tıklanınca detay sayfasına gitmesi için CupertinoButton eklendi
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
            _loadAllProfileData(); // Detaydan geri dönünce istatistikleri ve favorileri tazele
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    CupertinoIcons.lab_flask,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        recipe['description'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            AddRecipeScreen(recipeToEdit: recipe),
                      ),
                    );
                    _loadAllProfileData();
                  },
                  child: const Icon(
                    CupertinoIcons.pencil_circle_fill,
                    color: AppColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () => _deleteRecipe(recipe['id']),
                  child: const Icon(
                    CupertinoIcons.trash_circle_fill,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesSection() {
    if (_favoriteRecipes.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.heart_slash,
        title: 'Henüz favori tarifiniz yok.',
        subtitle: 'Beğendiğiniz tarifleri kalbe basarak ekleyin.',
      );
    }

    return ListView.builder(
      key: const ValueKey(1),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _favoriteRecipes.length,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemBuilder: (context, index) {
        final recipe = _favoriteRecipes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          child: RecipeCard(
            name: recipe['name'],
            image: recipe['image'],
            description: recipe['description'],
            prepTime: recipe['prep_time'],
            servings: recipe['servings'],
            difficulty: recipe['difficulty'],
            onTap: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
              _loadAllProfileData();
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.subText.withOpacity(0.35)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.subText),
          ),
        ],
      ),
    );
  }
}
