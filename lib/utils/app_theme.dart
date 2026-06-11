import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

class AppTheme {
  static const CupertinoThemeData lightTheme = CupertinoThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.card,
    textTheme: CupertinoTextThemeData(primaryColor: AppColors.text),
  );
}
