import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/screens/splash_screen.dart';
import 'package:mealio/utils/app_theme.dart';

void main() async {
  // Flutter engine ve binding altyapısını garantiye alıyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanını ilk açılışta tetikliyoruz, tablolar ve seed veriler otomatik oluşuyor
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Mealio',
      theme: AppTheme
          .lightTheme, // Tamamen bittiğinde kullanacağımız merkezi iOS teması
      home: SplashScreen(), // İlk olarak animasyonlu splash ekranı açılır
    );
  }
}
