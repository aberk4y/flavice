import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/widgets/menu_tile.dart';
import 'package:mealio/screens/recipe_detail_screen.dart';
import 'package:mealio/utils/tab_controller.dart';

class MyMenuScreen extends StatefulWidget {
  const MyMenuScreen({super.key});

  @override
  State<MyMenuScreen> createState() => _MyMenuScreenState();
}

class _MyMenuScreenState extends State<MyMenuScreen> {
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadMenu();

    TabControllerManager.refreshMenu.addListener(() {
      if (mounted) {
        _loadMenu();
      }
    });
  }

  @override
  void activate() {
    super.activate();
    _loadMenu();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final db = DatabaseHelper.instance;
    final data = await db.getMyMenu();
    if (mounted) {
      setState(() {
        _menuItems = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleItem(int menuEntryId, int currentStatus) async {
    final db = DatabaseHelper.instance;
    int newStatus = currentStatus == 1 ? 0 : 1;
    await db.toggleMenuItem(menuEntryId, newStatus);
    _loadMenu();
  }

  Future<void> _removeItem(int menuEntryId) async {
    final db = DatabaseHelper.instance;
    await db.removeFromMenu(menuEntryId);
    _loadMenu();
  }

  // Menüdeki her şeyin tamamlanıp tamamlanmadığını kontrol eden mantık
  bool get _isMenuCompleted {
    if (_menuItems.isEmpty) return false;
    return _menuItems.every((item) => item['is_completed'] == 1);
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
                  largeTitle: Text('Sofram'),
                  border: null,
                  backgroundColor: AppColors.background,
                ),

                // Eğer menü başarıyla tamamlandıysa en üstte lüks bir tebrik widget'ı gösteriyoruz
                if (_isMenuCompleted)
                  SliverToBoxAdapter(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, Color(0xFF81E797)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            color: CupertinoColors.white,
                            size: 28,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Menü Tamamlandı!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                Text(
                                  'Bugünkü sofran harika görünüyor, ellerine sağlık.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Menü Öğeleri Listesi
                _menuItems.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.circle_grid_hex,
                                size: 48,
                                color: AppColors.subText,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Bugün için bir menü seçilmedi.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.subText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tarif detayından sofrana ekleme yapabilirsin.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = _menuItems[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) =>
                                      RecipeDetailScreen(recipe: item),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.text.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(18),
                                    ),
                                    child: Image.asset(
                                      'assets/images/recipes/${item['image']}.jpg',
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Container(
                                          width: 110,
                                          height: 110,
                                          color: AppColors.primary.withOpacity(
                                            0.15,
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.photo,
                                            size: 32,
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.text,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          const Text(
                                            'Bugünkü Plan',
                                            style: TextStyle(
                                              color: AppColors.subText,
                                              fontSize: 13,
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => _toggleItem(
                                                  item['menu_entry_id'],
                                                  item['is_completed'],
                                                ),
                                                child: Icon(
                                                  item['is_completed'] == 1
                                                      ? CupertinoIcons
                                                            .checkmark_circle_fill
                                                      : CupertinoIcons.circle,
                                                  color:
                                                      item['is_completed'] == 1
                                                      ? AppColors.accent
                                                      : AppColors.subText,
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              Text(
                                                item['is_completed'] == 1
                                                    ? 'Hazır'
                                                    : 'Bekliyor',
                                                style: TextStyle(
                                                  color:
                                                      item['is_completed'] == 1
                                                      ? AppColors.accent
                                                      : AppColors.subText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minSize: 0,
                                        onPressed: () =>
                                            _removeItem(item['menu_entry_id']),
                                        child: const Icon(
                                          CupertinoIcons.minus_circle_fill,
                                          color: CupertinoColors.systemRed,
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      const Icon(
                                        CupertinoIcons.chevron_right,
                                        color: AppColors.subText,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          );
                        }, childCount: _menuItems.length),
                      ),
              ],
            ),
    );
  }
}
