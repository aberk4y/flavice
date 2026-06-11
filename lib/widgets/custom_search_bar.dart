import 'package:flutter/cupertino.dart';
import 'package:mealio/utils/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CupertinoSearchTextField(
        onChanged: onChanged,
        placeholder: 'Tarif veya malzeme ara...',
        backgroundColor: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        itemColor: AppColors.subText,
        style: const TextStyle(color: AppColors.text, fontSize: 16),
      ),
    );
  }
}
