import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:mealio/screens/home_screen.dart';
import 'package:mealio/screens/shopping_list_screen.dart';
import 'package:mealio/screens/my_menu_screen.dart';
import 'package:mealio/screens/my_recipes_screen.dart';
import 'package:mealio/screens/random_recipe_screen.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/utils/tab_controller.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late PageController _pageController;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    TabControllerManager.currentTab.addListener(() {
      if (mounted) {
        final targetIndex = TabControllerManager.currentTab.value;
        _animateToPage(targetIndex);
      }
    });
  }

  void _animateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onCenterDicePressed() {
    setState(() {
      _refreshCounter++;
    });
    _animateToPage(2);
    TabControllerManager.changeTab(2);
  }

  @override
  Widget build(BuildContext context) {
    // Sabit, her cihazda stabil duracak premium bar yüksekliği
    const double customBarHeight = 62.0;
    // Elemanların alt sınır çizgisine olan ideal mesafesi
    const double contentBottomPosition = 4.0;

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      // RESPONSIVE GÜNCELLEME: Tüm ekranı kaplayan Stack yapısı yerine,
      // cihazın sanal/fiziksel tuş sınırlarına saygı duyan SafeArea mimarisi kuruldu.
      child: SafeArea(
        bottom:
            true, // Sadece alt taraftaki tuşları/çizgileri koruma altına alıyoruz
        top: false,
        child: Stack(
          children: [
            // 1. KATMAN: İçerik Ekranları
            Positioned.fill(
              child: Padding(
                // İçeriklerin kavisli alt barın arkasında kalıp kesilmemesi için bar yüksekliği kadar alt boşluk
                padding: const EdgeInsets.only(bottom: customBarHeight),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    HomeScreen(key: ValueKey('home_$_refreshCounter')),
                    MyMenuScreen(key: ValueKey('menu_$_refreshCounter')),
                    RandomRecipeScreen(
                      key: ValueKey('random_$_refreshCounter'),
                    ),
                    ShoppingListScreen(
                      key: ValueKey('shopping_$_refreshCounter'),
                    ),
                    MyRecipesScreen(key: ValueKey('profile_$_refreshCounter')),
                  ],
                ),
              ),
            ),

            // 2. KATMAN: Akıcı Pürüzsüz Kavisli Alt Bar Zemini
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, customBarHeight),
                painter: _NotchedTabBarPainter(backgroundColor: AppColors.card),
              ),
            ),

            // 3. KATMAN: Premium Ölçeklendirilmiş Butonlar ve Yazılar
            Positioned(
              left: 0,
              right: 0,
              bottom: contentBottomPosition,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTabItem(0, CupertinoIcons.house_fill, 'Keşfet'),
                    _buildTabItem(
                      1,
                      CupertinoIcons.circle_grid_hex_fill,
                      'Sofram',
                    ),

                    // ORTADAKİ PREMIUM DENGELENMİŞ NE PİŞİRSEM BUTONU
                    GestureDetector(
                      onTap: _onCenterDicePressed,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 75,
                        height: 56,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              top: -24,
                              child: AnimatedScale(
                                scale: _currentIndex == 2 ? 1.10 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == 2
                                        ? AppColors.primary
                                        : AppColors.card,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _currentIndex == 2
                                            ? AppColors.primary.withOpacity(
                                                0.35,
                                              )
                                            : CupertinoColors.black.withOpacity(
                                                0.05,
                                              ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🎲',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 3.5,
                              child: Text(
                                'Ne Pişirsem',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: _currentIndex == 2
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _currentIndex == 2
                                      ? AppColors.primary
                                      : AppColors.subText,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildTabItem(3, CupertinoIcons.cart_fill, 'Listem'),
                    _buildTabItem(4, CupertinoIcons.person_fill, 'Profil'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _animateToPage(index);
        TabControllerManager.changeTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              icon,
              size: 23,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.subText.withOpacity(0.8),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.subText,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _NotchedTabBarPainter extends CustomPainter {
  final Color backgroundColor;
  _NotchedTabBarPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFE5E5EA).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final path = Path();
    final centerW = size.width / 2;

    path.moveTo(0, 0);
    path.lineTo(centerW - 58, 0);

    path.cubicTo(centerW - 40, 0, centerW - 36, -26, centerW, -26);

    path.cubicTo(centerW + 36, -26, centerW + 40, 0, centerW + 58, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
