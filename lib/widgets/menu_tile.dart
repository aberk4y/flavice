import 'package:flutter/cupertino.dart';
import 'package:mealio/utils/app_colors.dart';

class MenuTile extends StatelessWidget {
  final String name;
  final String categoryName;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const MenuTile({
    super.key,
    required this.name,
    required this.categoryName,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // iOS Tarzı Seçim İkonu
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isCompleted
                  ? CupertinoIcons.checkmark_seal_fill
                  : CupertinoIcons.circle,
              color: isCompleted ? AppColors.primary : AppColors.subText,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Yemek ve Kategori Metinleri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.subText : AppColors.text,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),
          // Kaldırma Butonu
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: onDelete,
            child: const Icon(
              CupertinoIcons.minus_circle_fill,
              color: CupertinoColors.systemRed,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
