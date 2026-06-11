import 'package:flutter/cupertino.dart';
import 'package:mealio/utils/app_colors.dart';

class RecipeCard extends StatelessWidget {
  final String name;
  final String description;
  final String prepTime;
  final String servings;
  final String difficulty;
  final VoidCallback onTap;
  final String image;

  const RecipeCard({
    super.key,
    required this.name,
    required this.description,
    required this.prepTime,
    required this.servings,
    required this.difficulty,
    required this.onTap,
    required this.image,
  });

  // Gradyan renkleri resim adına göre tutarlı seçiyoruz
  List<Color> _getGradient(String imageName) {
    final Map<String, List<Color>> gradients = {
      'mercimek_corbasi': [const Color(0xFFE8115B), const Color(0xFFBC0E4A)],
      'ezogelin': [const Color(0xFFFF8C42), const Color(0xFFd47030)],
      'domates_corbasi': [const Color(0xFFFF3B30), const Color(0xFFc42e25)],
      'yayla_corbasi': [const Color(0xFF34C759), const Color(0xFF28a046)],
      'tavuk_suyu_corbasi': [const Color(0xFF509BF5), const Color(0xFF3a7fd4)],
      'karniyarik': [const Color(0xFF8B5CF6), const Color(0xFF6d44d4)],
      'tavuk_sote': [const Color(0xFFFF9500), const Color(0xFFd47c00)],
      'hunkar_begendi': [const Color(0xFF5856D6), const Color(0xFF3d3bb5)],
      'manti': [const Color(0xFFFF2D55), const Color(0xFFcc2244)],
      'izmir_kofte': [const Color(0xFFFF6B35), const Color(0xFFd45520)],
      'sutlac': [const Color(0xFFA78BFA), const Color(0xFF8B6FD4)],
      'brownie': [const Color(0xFF6B3A2A), const Color(0xFF4a2218)],
      'tiramisu': [const Color(0xFF8B7355), const Color(0xFF6b5640)],
      'magnolia': [const Color(0xFFEC4899), const Color(0xFFc73880)],
      'mozaik_pasta': [const Color(0xFF1C1C1E), const Color(0xFF3a3a3c)],
      'menemen': [const Color(0xFFFF9500), const Color(0xFFd47c00)],
      'pankek': [const Color(0xFFFFCC00), const Color(0xFFd4a800)],
      'mihlama': [const Color(0xFFFF8C42), const Color(0xFFd47030)],
      'gözleme': [const Color(0xFF34C759), const Color(0xFF28a046)],
      'french_toast': [const Color(0xFFF59B23), const Color(0xFFd48319)],
    };
    return gradients[imageName] ??
        [const Color(0xFFFF8C42), const Color(0xFFd47030)];
  }

  // Her kategori için farklı ikon
  IconData _getIcon(String imageName) {
    if (imageName.contains('corba') ||
        imageName == 'ezogelin' ||
        imageName == 'yayla_corbasi') {
      return CupertinoIcons.drop_fill;
    } else if (imageName == 'brownie' ||
        imageName == 'tiramisu' ||
        imageName == 'sutlac' ||
        imageName == 'magnolia' ||
        imageName == 'mozaik_pasta') {
      return CupertinoIcons.star_fill;
    } else if (imageName == 'menemen' ||
        imageName == 'pankek' ||
        imageName == 'mihlama' ||
        imageName == 'french_toast' ||
        imageName == 'gözleme') {
      return CupertinoIcons.sun_max_fill;
    }
    return CupertinoIcons.flame_fill;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradient(image);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(left: 16, bottom: 16, top: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel alanı — gerçek asset varsa göster, yoksa gradyan
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  // Arka plan gradyanı (her zaman görünür)
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getIcon(image),
                        size: 52,
                        color: CupertinoColors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Asset resim varsa üstüne bindir
                  Image.asset(
                    'assets/images/recipes/$image.jpg',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Resim yoksa gradyan görünür kalır
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            // Alt içerik
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTag(
                        CupertinoIcons.clock,
                        prepTime,
                        AppColors.primary,
                      ),
                      _buildTag(
                        CupertinoIcons.person_2,
                        servings,
                        AppColors.accent,
                      ),
                      _buildTag(
                        CupertinoIcons.gauge,
                        difficulty,
                        CupertinoColors.systemBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
