import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Colors, CircleAvatar; // Gerekli Materyal bileşenleri
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/utils/tab_controller.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFav = false;
  bool _isLoading = true;

  late List<bool> _selectedIngredients;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    _checkFavoriteStatus();

    final ingredients = widget.recipe['ingredients']
        .toString()
        .split(RegExp(r'[\n,]'))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    _selectedIngredients = List.generate(ingredients.length, (_) => true);
  }

  Future<void> _checkFavoriteStatus() async {
    final db = DatabaseHelper.instance;
    bool favStatus = await db.isFavorite(widget.recipe['id']);
    if (mounted) {
      setState(() {
        _isFav = favStatus;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final db = DatabaseHelper.instance;
    if (_isFav) {
      await db.removeFavorite(widget.recipe['id']);
    } else {
      await db.addFavorite(widget.recipe['id']);
    }
    setState(() {
      _isFav = !_isFav;
    });
  }

  Future<void> _addToShoppingList() async {
    final db = DatabaseHelper.instance;

    final ingredients = widget.recipe['ingredients']
        .toString()
        .split(RegExp(r'[\n,]'))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    for (int i = 0; i < ingredients.length; i++) {
      if (_selectedIngredients[i]) {
        await db.addShoppingItem(ingredients[i].trim());
      }
    }
    TabControllerManager.notifyShoppingChanged();
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Başarılı'),
        content: const Text('Seçili malzemeler alışveriş listenize eklendi.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Listeme Git'),
            onPressed: () {
              TabControllerManager.changeTab(3);

              Navigator.of(context, rootNavigator: true).pop();

              Navigator.of(this.context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addToMenu() async {
    final db = DatabaseHelper.instance;
    await db.addToMenu(widget.recipe['id']);

    TabControllerManager.notifyMenuChanged();

    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sofraya Eklendi'),
        content: Text('${widget.recipe['name']} sofrana eklendi.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Soframa Git'),
            onPressed: () {
              TabControllerManager.changeTab(1);

              Navigator.of(context, rootNavigator: true).pop();

              Navigator.of(this.context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> ingredients = widget.recipe['ingredients']
        .toString()
        .split(RegExp(r'[\n,]'))
        .where((e) => e.trim().isNotEmpty)
        .toList();
    List<String> instructions = widget.recipe['instructions']
        .toString()
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.recipe['name']),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _toggleFavorite,
                child: Icon(
                  _isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: _isFav ? Colors.red : AppColors.primary,
                ),
              ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GÖRSEL ALANI
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Arka plan gradyanı
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, const Color(0xFFFFB37E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Gerçek resim
                    Image.asset(
                      'assets/images/recipes/${widget.recipe['image']}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 64,
                          color: CupertinoColors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    // Alt gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. DETAYLAR VE AKSİYON BUTONLARI
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe['name'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.recipe['description'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meta Bilgiler
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(
                          CupertinoIcons.clock,
                          widget.recipe['prep_time'],
                          'Süre',
                        ),
                        _buildMetaItem(
                          CupertinoIcons.person_2,
                          widget.recipe['servings'],
                          'Porsiyon',
                        ),
                        _buildMetaItem(
                          CupertinoIcons.gauge,
                          widget.recipe['difficulty'],
                          'Zorluk',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Aksiyon Butonları (Düzeltildi ve Esneklik Eklendi)
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 4,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _addToMenu,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    CupertinoIcons.circle_grid_hex_fill,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Sofraya Ekle',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoButton(
                            color: AppColors.accent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 4,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _addToShoppingList,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(CupertinoIcons.cart_fill, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Alışverişe Ekle',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // 3. İÇİNDEKİLER (Parantez kaçması düzeltilerek ana hizaya getirildi)
                    const Text(
                      'Malzemeler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ingredients.length,
                        separatorBuilder: (context, index) => Container(
                          height: 0.5,
                          color: AppColors.divider,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        itemBuilder: (context, index) {
                          if (ingredients[index].trim().isEmpty)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIngredients[index] =
                                          !_selectedIngredients[index];
                                    });
                                  },
                                  child: Icon(
                                    _selectedIngredients[index]
                                        ? CupertinoIcons.checkmark_circle_fill
                                        : CupertinoIcons.circle,
                                    size: 20,
                                    color: _selectedIngredients[index]
                                        ? AppColors.accent
                                        : AppColors.subText,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  ingredients[index].trim(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 4. YAPILIŞI
                    const Text(
                      'Hazırlanışı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(instructions.length, (index) {
                        String stepText = instructions[index].trim();

                        stepText = stepText.replaceFirst(
                          RegExp(r'^\d+\.\s*'),
                          '',
                        );
                        if (stepText.isEmpty) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  stepText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.text,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  Widget _buildMetaItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.subText),
          ),
        ],
      ),
    );
  }
}
