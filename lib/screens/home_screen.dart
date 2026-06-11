import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/screens/category_screen.dart';
import 'package:mealio/screens/recipe_detail_screen.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/widgets/recipe_card.dart';
import 'package:flutter/material.dart' show Colors;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<List<Color>> _categoryGradients = [
    [const Color(0xFFE8115B), const Color(0xFFBC0E4A)],
    [const Color(0xFF1DB954), const Color(0xFF1aa34a)],
    [const Color(0xFF509BF5), const Color(0xFF407cc4)],
    [const Color(0xFFF59B23), const Color(0xFFd48319)],
    [const Color(0xFF8B5CF6), const Color(0xFF6D44D4)],
    [const Color(0xFFFF6B35), const Color(0xFFD45520)],
  ];

  final List<IconData> _categoryIcons = [
    CupertinoIcons.drop_fill,
    CupertinoIcons.flame_fill,
    CupertinoIcons.star_fill,
    CupertinoIcons.sun_max_fill,
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    if (_searchQuery.isEmpty) return _recipes;
    final q = _searchQuery.toLowerCase();
    return _recipes
        .where(
          (r) =>
              r['name'].toString().toLowerCase().contains(q) ||
              r['ingredients'].toString().toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final db = DatabaseHelper.instance;
    final categoriesData = await db.getCategories();
    final recipesData = await db.getAllRecipes();
    if (mounted) {
      setState(() {
        _categories = categoriesData;
        _recipes = recipesData;
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
                // ── NAV BAR ──
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await _loadInitialData();
                  },
                ),
                CupertinoSliverNavigationBar(
                  largeTitle: const Text('Merhaba, Şef!'),
                  border: null,
                  backgroundColor: AppColors.background,
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── ARAMA ÇUBUĞU (en üstte) ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: CupertinoTextField(
                          controller: _searchController,
                          placeholder: '🔍  Tarif veya malzeme ara...',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.text.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.text,
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                        ),
                      ),

                      // ── ARAMA SONUÇLARI ──
                      if (_searchQuery.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            '${_filteredRecipes.length} sonuç bulundu',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 290,
                          child: _filteredRecipes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Sonuç bulunamadı',
                                    style: TextStyle(color: AppColors.subText),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _filteredRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = _filteredRecipes[index];
                                    return RecipeCard(
                                      name: recipe['name'],
                                      image: recipe['image'],
                                      description: recipe['description'],
                                      prepTime: recipe['prep_time'],
                                      servings: recipe['servings'],
                                      difficulty: recipe['difficulty'],
                                      onTap: () => Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) => RecipeDetailScreen(
                                            recipe: recipe,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── NORMAL İÇERİK (arama yoksa) ──
                      if (_searchQuery.isEmpty) ...[
                        // Günün Önerisi Banner
                        _buildDailyBanner(),
                        const SizedBox(height: 24),

                        // Popüler Tarifler
                        _buildSectionHeader('Popüler Tarifler', null),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 290,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _recipes.length > 6
                                ? 6
                                : _recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _recipes[index];
                              return RecipeCard(
                                name: recipe['name'],
                                image: recipe['image'],
                                description: recipe['description'],
                                prepTime: recipe['prep_time'],
                                servings: recipe['servings'],
                                difficulty: recipe['difficulty'],
                                onTap: () => Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Kategoriler
                        _buildSectionHeader('Kategoriler', null),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),

                // ── KATEGORİ GRID (arama yoksa) ──
                if (_searchQuery.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final category = _categories[index];
                        final gradient =
                            _categoryGradients[index %
                                _categoryGradients.length];
                        final icon =
                            _categoryIcons[index % _categoryIcons.length];

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => CategoryScreen(
                                categoryId: category['id'],
                                categoryName: category['name'],
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: gradient[0].withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Arka dekor ikon
                                Positioned(
                                  bottom: -12,
                                  right: -12,
                                  child: Icon(
                                    icon,
                                    size: 90,
                                    color: CupertinoColors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ),
                                // Kategori resmi
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    category['image'],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                                // Gradient overlay + isim
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        gradient[1].withValues(alpha: 0.75),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        category['name'],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoColors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _categories.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  Widget _buildDailyBanner() {
    if (_recipes.isEmpty) return const SizedBox.shrink();
    // Her gün farklı bir tarif göster (gün sayısına göre index)
    final dayIndex = DateTime.now().day % _recipes.length;
    final featured = _recipes[dayIndex];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: featured),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Resim
              Image.asset(
                'assets/images/recipes/${featured['image']}.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFFB37E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Koyu gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Etiket + içerik
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✨ Günün Tarifi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featured['name'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.clock,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              featured['prep_time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              CupertinoIcons.person_2,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              featured['servings'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
          ),
          if (onTap != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: onTap,
              child: const Text(
                'Tümü',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
