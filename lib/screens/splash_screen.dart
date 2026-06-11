import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:mealio/screens/main_wrapper.dart';
import 'package:mealio/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  double _screenOpacity = 0.0;

  // Satürn halkası efekti için her nesneye rastgelelik katacak sabit listeler
  final List<IconData> _kitchenIcons = [
    CupertinoIcons.selection_pin_in_out, // Çatal benzeri asil gurme ikonu
    CupertinoIcons.flame, // Pişirme/Ateş
    CupertinoIcons.drop, // Lezzet damlası
    CupertinoIcons.timer, // Zamanlayıcı
    CupertinoIcons.lab_flask, // Tarif denemeleri
    CupertinoIcons.gauge, // Gurme hassasiyetsi
  ];

  // 12 adet nesne için yörünge yarıçapı sapmaları (Satürn halkası gibi geniş ve dağınık olması için)
  late List<double> _randomRadii;
  // İkonların halka üzerinde farklı başlangıç noktalarına dağılması için açılar
  late List<double> _randomAngles;
  // İkonların kendi içindeki mikro dönüş varyasyonları
  late List<double> _iconRotations;

  @override
  void initState() {
    super.initState();

    // Rastgelelik tohumlarını ekiyoruz
    final rand = math.Random();
    _randomRadii = List.generate(
      12,
      (index) => 95.0 + rand.nextDouble() * 35.0,
    ); // 95 ile 130 arası dağınık yörüngeler
    _randomAngles = List.generate(
      12,
      (index) => (2 * math.pi / 12) * index + (rand.nextDouble() * 0.4),
    );
    _iconRotations = List.generate(12, (index) => rand.nextDouble() * math.pi);

    // Ana yörünge dönüş kontrolcüsü
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 6000,
      ), // Sakin ve lüks akış için 6 saniye
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _startSplashScreenSequence();
  }

  void _startSplashScreenSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _screenOpacity = 1.0;
      });
    }

    await Future.delayed(const Duration(milliseconds: 3400));

    if (mounted) {
      _animationController.stop();
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const MainWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Center(
        child: AnimatedOpacity(
          opacity: _screenOpacity,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Mum ışığı gibi yavaşça dalgalanan (Pulsing) arka plan aydınlatması
              double pulseValue =
                  (math.sin(_animationController.value * 2 * math.pi) + 1) / 2;
              double blurRadiusValue = 45.0 + (pulseValue * 30.0);

              return SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. KATMAN: Arkada yavaşça soluklanıp parlayan Gurme Glow efekti
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(
                              0.15 * pulseValue,
                            ),
                            blurRadius: blurRadiusValue,
                            spreadRadius: 6.0,
                          ),
                          BoxShadow(
                            color: const Color(
                              0xFFFF9E6D,
                            ).withOpacity(0.10 * pulseValue),
                            blurRadius: blurRadiusValue * 1.3,
                            spreadRadius: 1.0,
                            offset: const Offset(
                              0,
                              0,
                            ), // HATA DÜZELTİLDİ: Positional hale getirildi
                          ),
                        ],
                      ),
                    ),

                    // 2. KATMAN: Satürn Halkası gibi dağınık dönen amorf mutfak aletleri
                    ..._buildSaturnOrbitIcons(),

                    // 3. KATMAN: Merkezde çakılı duran pürüzsüz premium logo kartı
                    Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 6), // HATA DÜZELTİLDİ
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.card,
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.photo_on_rectangle,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // SATÜRN HALKASI MANTIĞINDA DAĞINIK İKON BULUTU OLUŞTURUCU
  List<Widget> _buildSaturnOrbitIcons() {
    return List.generate(12, (index) {
      final iconData = _kitchenIcons[index % _kitchenIcons.length];
      final radius = _randomRadii[index];
      final baseAngle = _randomAngles[index];
      final staticRotation = _iconRotations[index];

      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          // İkonun anlık açısı (Dönüş yönü ve hızı dinamik harmanlanır)
          double currentAngle = _rotationAnimation.value + baseAngle;

          // Dairesel trigonometrik koordinat izdüşümü
          double x = radius * math.cos(currentAngle);
          double y = radius * math.sin(currentAngle);

          return Transform.translate(
            offset: Offset(x, y), // HATA DÜZELTİLDİ: Positional yapıldı
            child: Transform.rotate(
              // İkonların yörüngede sürüklenirken Satürn halkasındaki toz bulutları gibi
              // hafif eğik ve serbest açılarda akması için asimetrik rotasyon kurgusu
              angle: _rotationAnimation.value + staticRotation,
              child: Opacity(
                // Merkezden uzaklaştıkça hafifçe flulaşan derinlik algısı
                opacity: (1.3 - (radius / 140.0)).clamp(0.4, 0.85),
                child: Icon(
                  iconData,
                  size: 16, // Zarif ve minik premium ikon boyutları
                  color: index % 2 == 0
                      ? AppColors.primary.withOpacity(0.8)
                      : const Color(0xFFFF9E6D).withOpacity(0.8),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
