import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/screens/recipe_detail_screen.dart';
import 'package:mealio/utils/app_colors.dart';

class RandomRecipeScreen extends StatefulWidget {
  const RandomRecipeScreen({super.key});

  @override
  State<RandomRecipeScreen> createState() => _RandomRecipeScreenState();
}

class _RandomRecipeScreenState extends State<RandomRecipeScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _allRecipes = [];
  int? _selectedCategoryId;
  String _selectedCategoryName = 'Tümü';
  Map<String, dynamic>? _result;
  bool _isLoading = true;
  bool _isSpinning = false;

  // Sonuç kartı için animasyonlar
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Zarın kendi etrafında dönmesi için animasyon controller'ı
  late AnimationController _spinController;

  // Kategori sürgüsünün smooth kayması ve sonuç odaklaması için key listesi
  final List<GlobalKey> _categoryKeys = [GlobalKey()];
  final GlobalKey _resultCardKey =
      GlobalKey(); // Sonuç butonuna odaklanmak için yeni key

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ).drive(Tween(begin: 0.85, end: 1.0));
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final cats = await db.getCategories();
    final recipes = await db.getAllRecipes();

    if (mounted) {
      setState(() {
        _categories = cats;
        _categoryKeys.addAll(List.generate(cats.length, (_) => GlobalKey()));
        _allRecipes = recipes;
        _isLoading = false;
      });
    }
  }

  void _scrollToCategory(int index) {
    final context = _categoryKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // Sonuç kartı açıldığında butonu otomatik görünür alana getiren akıllı scroll lojiği
  void _scrollToResultButton() async {
    await Future.delayed(const Duration(milliseconds: 550));
    final context = _resultCardKey.currentContext;
    if (context != null && mounted) {
      Scrollable.ensureVisible(
        context,
        alignment:
            0.9, // Butonu ekranın alt kısmında kavisli barın hemen üzerinde mükemmel konumlandırır
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _spin() async {
    setState(() {
      _isSpinning = true;
      _result = null;
    });
    _controller.reset();
    _spinController.forward(from: 0.0);

    await Future.delayed(const Duration(milliseconds: 700));

    List<Map<String, dynamic>> pool = _selectedCategoryId == null
        ? _allRecipes
        : _allRecipes
              .where((r) => r['category_id'] == _selectedCategoryId)
              .toList();

    if (pool.isEmpty) {
      setState(() => _isSpinning = false);
      return;
    }

    final random = Random();
    final picked = pool[random.nextInt(pool.length)];

    setState(() {
      _result = picked;
      _isSpinning = false;
    });
    _controller.forward();
    _scrollToResultButton(); // Butona otomatik odaklanmayı tetikle
  }

  @override
  Widget build(BuildContext context) {
    // Cihazın alt sistem yüksekliği hesaplanarak dinamik alt boşluk kurgulanıyor
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    final double mainBarHeight =
        64.0 + (systemBottomPadding > 0 ? systemBottomPadding * 0.6 : 12.0);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const CupertinoSliverNavigationBar(
                  largeTitle: Text(
                    'Ne Pişirsem?',
                    style: TextStyle(
                      letterSpacing: -1.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  border: null,
                  backgroundColor: AppColors.background,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Kararsız mı kaldın? Kategorini seç, zarını at, ve sana özel bir tarifle tanış!',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.subText,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  key: _categoryKeys[0],
                                  padding: const EdgeInsets.only(right: 2.0),
                                  child: _buildModernTabItem(null, 'Tümü', 0),
                                );
                              }
                              final cat = _categories[index - 1];
                              return Padding(
                                key: _categoryKeys[index],
                                padding: const EdgeInsets.only(right: 2.0),
                                child: _buildModernTabItem(
                                  cat['id'],
                                  cat['name'],
                                  index,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 48),

                        Center(
                          child: GestureDetector(
                            onTap: _isSpinning ? null : _spin,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: _isSpinning ? 150 : 120,
                                  height: _isSpinning ? 150 : 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: _isSpinning ? 0.25 : 0.08,
                                        ),
                                        blurRadius: _isSpinning ? 45 : 25,
                                        spreadRadius: _isSpinning ? 10 : 0,
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedScale(
                                  scale: _isSpinning ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: RotationTransition(
                                    turns: Tween<double>(begin: 0.0, end: 2.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _spinController,
                                            curve: Curves.easeInOutBack,
                                          ),
                                        ),
                                    child: const SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Center(
                                        child: Text(
                                          '🎲',
                                          style: TextStyle(fontSize: 56),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ── EDİTORİAL TARİF SUNUMU ──
                        if (_result != null)
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) => Opacity(
                              opacity: _fadeAnim.value,
                              child: Transform.scale(
                                scale: _scaleAnim.value,
                                child: child,
                              ),
                            ),
                            child: _buildEditorialRecipeView(_result!),
                          ),

                        // DEĞİŞİKLİK: Sayfanın alt bar arkasında kalıp geri fırlamasını
                        // engellemek için dinamik alt bar yüksekliği + güvenli alan payı eklendi
                        SizedBox(height: mainBarHeight + 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernTabItem(int? categoryId, String name, int globalIndex) {
    final isSelected = _selectedCategoryId == categoryId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = categoryId;
          _selectedCategoryName = name;
          _result = null;
        });
        _scrollToCategory(globalIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF9E6D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.card,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.divider.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? CupertinoColors.white : AppColors.text,
            letterSpacing: -0.1,
          ),
          child: Text(name),
        ),
      ),
    );
  }

  Widget _buildEditorialRecipeView(Map<String, dynamic> recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ŞANSLI SEÇİMİN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary.withValues(alpha: 0.9),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(44),
                        bottomRight: Radius.circular(44),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      color: CupertinoColors.systemGroupedBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(44),
                        bottomRight: Radius.circular(44),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/recipes/${recipe['image']}.jpg',
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            CupertinoIcons.infinite,
                            size: 32,
                            color: CupertinoColors.inactiveGray,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        recipe['difficulty'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                recipe['name'],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe['description'] ??
                    'Malzemelerin mükemmel uyumuyla hazırlanmış enfes bir modern lezzet reçetesi.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _buildInlineInfo(CupertinoIcons.clock, recipe['prep_time']),
                  _buildDotSeparator(),
                  _buildInlineInfo(
                    CupertinoIcons.person,
                    '${recipe['servings']} Kişi',
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // DEĞİŞİKLİK: Scrollable hedefi olması ve butonun görünür kılınması için key buraya bağlandı
              Container(
                key: _resultCardKey,
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Yapılışına Göz At',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        CupertinoIcons.arrow_right,
                        size: 16,
                        color: CupertinoColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.secondaryLabel.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.subText,
          ),
        ),
      ],
    );
  }

  Widget _buildDotSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.separator.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
