import 'package:flutter/cupertino.dart';
import 'package:mealio/utils/app_colors.dart';

class ShoppingTile extends StatelessWidget {
  final String name;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ShoppingTile({
    super.key,
    required this.name,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(
              alpha: 0.02,
            ), // Yeni güncelleme standardına uyarlandı
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              // HATA DÜZELTİLDİ: checkmark_circle_fill yapıldı
              isCompleted
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: isCompleted ? AppColors.accent : AppColors.subText,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isCompleted ? AppColors.subText : AppColors.text,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0, // Deprecated uyarısı düzeltildi
            onPressed: onDelete,
            child: const Icon(
              CupertinoIcons.trash,
              color: CupertinoColors.systemRed,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
