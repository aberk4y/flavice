Mobil Uygulama ve Geliştirme Dersi Final Projesi

Berkay Aras - 23040301055
Yazılım Mühendisliği 3.Sınıf



# 🎲 Flavice - Kararsız Anlar İçin Akıllı Yemek Seçici

<p align="center">
  <b>Mutfakta kararsız kalan şeflerin modern asistanı.</b><br>
  Flavice, "Ne Pişirsem?" derdine Bezier eğrileriyle şekillendirilmiş premium tasarımı, akıcı animasyonları ve şans odaklı akıllı lojiğiyle lüks bir çözüm sunan, tamamen modern Cupertino (iOS) tasarım diline sadık kalınarak geliştirilmiş bir mobil yemek uygulamasıdır.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-apple?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/UI%2FUX-Cupertino%20Premium-FF6B35?style=for-the-badge" alt="UI">
</p>

---

## ✨ Öne Çıkan Özellikler

* **🎲 Ne Pişirsem? (Gurme Zarı):** Kategorini seç, lüks animasyonlu zarı at ve akıllı algoritmanın sana özel seçtiği editorial tarifle tanış!
* **曲线 Premium Center-Raised Tab Bar:** Alt bar iskeleti sıradan düz çizgiler yerine sıfırdan `CustomPainter` ve *Bezier* matematiği kullanılarak çizildi. Ortadaki gurme zarı, yukarı doğru pürüzsüz bir yumru şeklinde taşarak premium bir derinlik hissi sunar.
* **🍃 Akıcı Sayfa Geçişleri (Smooth Transition):** `PageView` ve `PageController` mimarisi üzerine kurulu sistem, sayfalar arası geçişi `Curves.easeInOutCubic` ivmesiyle yağ gibi akan, süzülen bir animasyona dönüştürür.
* **📅 Dinamik Günün Tarifi:** Her gün gece 00:00'dan sonra takvim gününe (`DateTime.now().day`) göre veri tabanından otomatik hesaplanan, kendini tekrar etmeyen tutarlı "Günün Menüsü" mekanizması.
* **🔍 Gelişmiş Malzeme ve Tarif Arama:** Veri tabanındaki tüm tarifleri hem isimlerine hem de içerdikleri malzemelere göre milisaniyeler içinde süzen akıllı filtreleme.
* **📱 %100 Responsive & Güvenli Alan:** Hem çentikli (iOS/Yeni Nesil Android) ekranlarda hem de eski nesil sanal üç tuşlu Android cihazlarda tuş şeritlerinin üstüne kusursuz konumlanan `SafeArea` mimarisi.

---

## 🚀 Teknolojik Mimari & Klasör Yapısı

Flavice, temiz kod (Clean Code) standartlarında ve modüler bir klasör hiyerarşisiyle tasarlanmıştır:

```text
lib/
├── database/     # SQLite / DatabaseHelper lojikleri
├── models/       # Recipe, Category, ShoppingItem veri modelleri
├── screens/      # HomeScreen, RandomRecipeScreen, MainWrapper (Ana İskelet)
├── utils/        # AppColors, AppTheme, TabControllerManager (State)
└── widgets/      # RecipeCard, MenuTile, CategoryCard gibi atomik bileşenler
