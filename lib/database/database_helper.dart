import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mealio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('DATABASE FILE: $path');
    return await openDatabase(
      path,
      version: 11,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS my_menu');
        await db.execute('DROP TABLE IF EXISTS shopping_list');
        await db.execute('DROP TABLE IF EXISTS favorites');
        await db.execute('DROP TABLE IF EXISTS user_recipes');
        await db.execute('DROP TABLE IF EXISTS recipes');
        await db.execute('DROP TABLE IF EXISTS categories');
        await _createDB(db, newVersion);
      },
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL,
        image TEXT NOT NULL,
        prep_time TEXT NOT NULL,
        servings TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL UNIQUE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_name TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE my_menu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL UNIQUE,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL,
        image TEXT,
        prep_time TEXT NOT NULL,
        servings TEXT NOT NULL,
        difficulty TEXT NOT NULL
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    int corbaId = await db.insert('categories', {
      'name': 'Çorbalar',
      'image': 'assets/images/categories/corbalar.jpg',
    });
    int anaYemekId = await db.insert('categories', {
      'name': 'Ana Yemekler',
      'image': 'assets/images/categories/anayemekler.jpg',
    });
    int tatliId = await db.insert('categories', {
      'name': 'Tatlılar',
      'image': 'assets/images/categories/tatlilar.jpg',
    });
    int kahvaltiId = await db.insert('categories', {
      'name': 'Kahvaltılık',
      'image': 'assets/images/categories/kahvaltiliklar.jpg',
    });
    int salataId = await db.insert('categories', {
      'name': 'Salatalar',
      'image': 'assets/images/categories/salatalar.jpg',
    });

    int hamurisiId = await db.insert('categories', {
      'name': 'Hamur İşleri',
      'image': 'assets/images/categories/hamurisleri.jpg',
    });

    // ==========================================
    // 1. ÇORBALAR (5 TARİF)
    // ==========================================
    List<Map<String, dynamic>> corbalar = [
      {
        'category_id': corbaId,
        'name': 'Mercimek Çorbası',
        'description':
            'Lokanta usulü kıvamında, besleyici and doyurucu klasik Türk çorbası.',
        'ingredients': '''
1 su bardağı kırmızı mercimek
1 adet orta boy kuru soğan
1 adet havuç
1 adet orta boy patates
1 yemek kaşığı tereyağı
1 yemek kaşığı sıvı yağ
6 su bardağı sıcak su
1 tatlı kaşığı tuz

Sosu İçin:
1 yemek kaşığı tereyağı
1 tatlı kaşığı kırmızı toz biber
''',
        'instructions': '''
1. Kırmızı mercimeği bol suyla yıkayıp süzün.

2. Soğanı yemeklik doğrayın, havuç ve patatesi küp küp kesin.

3. Tencereye tereyağı ve sıvı yağı alın.

4. Soğanları pembeleşene kadar kavurun.

5. Havuç ve patatesi ekleyip 2-3 dakika soteleyin.

6. Yıkanmış mercimeği ilave edin.

7. Sıcak suyu ekleyin ve kaynamaya bırakın.

8. Kaynadıktan sonra kısık ateşte yaklaşık 30 dakika pişirin.

9. Tüm malzemeler yumuşayınca blenderdan geçirerek pürüzsüz hale getirin.

10. Tuzunu ekleyip birkaç dakika daha kaynatın.

11. Ayrı bir tavada tereyağını eritip kırmızı toz biberi kavurun.

12. Hazırladığınız sosu çorbanın üzerine gezdirin.

13. Limon eşliğinde sıcak servis edin.
''',
        'image': 'mercimek_corbasi',
        'prep_time': '40 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': corbaId,
        'name': 'Ezogelin Çorbası',
        'description':
            'Kırmızı mercimek, bulgur ve pirincin eşsiz uyumuyla hazırlanan geleneksel Anadolu lezzeti.',
        'ingredients': '''
1 su bardağı kırmızı mercimek
2 yemek kaşığı ince bulgur
2 yemek kaşığı pirinç
1 adet orta boy kuru soğan
1 yemek kaşığı domates salçası
1 yemek kaşığı tereyağı
1 yemek kaşığı sıvı yağ
7 su bardağı sıcak su
1 tatlı kaşığı tuz

Sosu İçin:
1 yemek kaşığı tereyağı
1 tatlı kaşığı kuru nane
1 çay kaşığı kırmızı toz biber
''',
        'instructions': '''

1. Mercimek, bulgur ve pirinci bol suyla yıkayıp süzün.

2. Soğanı yemeklik doğrayın.

3. Tencereye tereyağı ve sıvı yağı alın.

4. Soğanları pembeleşene kadar kavurun.

5. Domates salçasını ekleyip kokusu çıkana kadar kavurun.

6. Mercimek, bulgur ve pirinci ilave edin.

7. Sıcak suyu ekleyerek kaynamaya bırakın.

8. Kaynadıktan sonra kısık ateşte yaklaşık 35 dakika pişirin.

9. Bakliyatlar iyice yumuşayınca blenderdan kısa süre geçirerek kıvam verin.

10. Tuzunu ekleyin.

11. Ayrı bir tavada tereyağını eritip nane ve kırmızı biberi kavurun.

12. Hazırladığınız sosu çorbaya ekleyin.

13. Birkaç dakika daha kaynatıp sıcak servis edin.
    ''',
        'image': 'ezogelin',
        'prep_time': '45 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Orta',
      },

      {
        'category_id': corbaId,
        'name': 'Domates Çorbası',
        'description':
            'Taze domates ve kaşar peyniriyle hazırlanan yumuşak içimli klasik çorba.',
        'ingredients': '''
5 adet olgun domates
1 yemek kaşığı un
1 yemek kaşığı tereyağı
1 yemek kaşığı sıvı yağ
4 su bardağı sıcak su
1 su bardağı süt
1 çay kaşığı tuz

Servis İçin:
Rendelenmiş kaşar peyniri
''',
        'instructions': '''

1. Domatesleri rendeleyin veya rondodan geçirin.

2. Tencereye tereyağı ve sıvı yağı alın.

3. Unu ekleyip hafif renk alana kadar kavurun.

4. Rendelenmiş domatesleri ilave edin.

5. Domates suyunu çekene kadar birkaç dakika pişirin.

6. Sıcak suyu yavaş yavaş ekleyin.

7. Sürekli karıştırarak kaynamasını sağlayın.

8. Çorba kaynadıktan sonra kısık ateşte 15 dakika pişirin.

9. Sütü ve tuzu ekleyin.

10. Birkaç dakika daha kaynatıp ocaktan alın.

11. Kaselere paylaştırın.

12. Üzerine rendelenmiş kaşar peyniri serperek servis edin.
    ''',
        'image': 'domates_corbasi',
        'prep_time': '30 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': corbaId,
        'name': 'Yayla Çorbası',
        'description':
            'Yoğurt ve nane aromasıyla hazırlanan hafif, ferahlatıcı ve geleneksel lezzet.',
        'ingredients': '''
1 çay bardağı pirinç
1 su bardağı yoğurt
1 adet yumurta sarısı
1 yemek kaşığı un
5 su bardağı su
1 tatlı kaşığı tuz

Üzeri İçin:
1 yemek kaşığı tereyağı
1 tatlı kaşığı kuru nane
''',
        'instructions': '''

1. Pirinci yıkayıp tencereye alın.

2. Suyu ekleyerek pirinçler yumuşayana kadar haşlayın.

3. Ayrı bir kapta yoğurt, yumurta sarısı ve unu çırpın.

4. Kaynayan çorbanın suyundan birkaç kepçe alıp terbiyeye ekleyin.

5. Terbiyeyi yavaş yavaş çorbaya ilave edin.

6. Sürekli karıştırarak kesilmesini önleyin.

7. Tuzunu ekleyin.

8. Kısık ateşte 10 dakika daha pişirin.

9. Ayrı bir tavada tereyağını eritip naneyi kavurun.

10. Naneli sosu çorbanın üzerine gezdirin.

11. Sıcak olarak servis edin.
    ''',
        'image': 'yayla_corbasi',
        'prep_time': '30 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': corbaId,
        'name': 'Tavuk Suyu Çorbası',
        'description':
            'Şifa deposu tavuk suyu, tel şehriye ve limon aromasıyla hazırlanan klasik lezzet.',
        'ingredients': '''
1 adet tavuk göğsü
1 çay bardağı tel şehriye
1 adet havuç
1 diş sarımsak
6 su bardağı su
1 tatlı kaşığı tuz

Terbiyesi İçin:
1 adet yumurta sarısı
1 yemek kaşığı limon suyu
''',
        'instructions': '''

1. Tavuk göğsünü su ile birlikte tencereye alın.

2. Havuç ve sarımsağı ekleyin.

3. Tavuk tamamen yumuşayana kadar haşlayın.

4. Tavukları çıkarıp didikleyin.

5. Çorbanın suyunu süzerek tekrar tencereye alın.

6. Tel şehriyeyi ekleyin.

7. Şehriyeler yumuşayana kadar pişirin.

8. Didiklenmiş tavukları tekrar çorbaya ilave edin.

9. Ayrı bir kapta yumurta sarısı ve limon suyunu çırpın.

10. Çorbanın suyundan birkaç kaşık alarak terbiyeye ekleyin.

11. Terbiyeyi yavaşça çorbaya karıştırın.

12. Tuzunu ekleyin.

13. Bir taşım daha kaynatıp sıcak servis edin.
    ''',
        'image': 'tavuk_suyu_corbasi',
        'prep_time': '50 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Orta',
      },
    ];

    // ==========================================
    // 2. ANA YEMEKLER (5 TARİF)
    // ==========================================
    List<Map<String, dynamic>> anaYemekler = [
      {
        'category_id': anaYemekId,
        'name': 'Karnıyarık',
        'description':
            'Kızartılmış patlıcanların kıymalı harçla buluştuğu geleneksel Türk mutfağının vazgeçilmez lezzeti.',
        'ingredients': '''
4 adet orta boy patlıcan
300 gram dana kıyma
1 adet büyük kuru soğan
2 adet yeşil biber
2 adet domates
2 diş sarımsak
3 yemek kaşığı sıvı yağ
1 yemek kaşığı domates salçası
1 çay bardağı sıcak su
1 tatlı kaşığı tuz
1 çay kaşığı karabiber

Kızartmak İçin:
Sıvı yağ
''',
        'instructions': '''

1. Patlıcanları alacalı soyup tuzlu suda 20 dakika bekletin.

2. Patlıcanları kurulayarak kızgın yağda hafifçe kızartın.

3. Soğanı ve sarımsağı ince ince doğrayın.

4. Tavaya sıvı yağı alıp soğanları kavurun.

5. Kıymayı ekleyerek suyunu çekene kadar kavurun.

6. Doğranmış biberleri ilave edin.

7. Küp doğranmış domatesleri ve salçayı ekleyin.

8. Tuz ve karabiber ile tatlandırın.

9. Harcı 5 dakika daha pişirin.

10. Patlıcanları fırın tepsisine dizin.

11. Ortalarını açarak hazırladığınız harçla doldurun.

12. Üzerlerine domates ve biber dilimleri yerleştirin.

13. Sıcak suyu tepsiye ekleyin.

14. Önceden ısıtılmış 190 derece fırında yaklaşık 30 dakika pişirin.

15. Sıcak servis edin.
    ''',
        'image': 'karniyarik',
        'prep_time': '75 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Orta',
      },

      {
        'category_id': anaYemekId,
        'name': 'Et Sote',
        'description':
            'Lokanta usulü dana eti ve renkli sebzelerle hazırlanan doyurucu ana yemek.',
        'ingredients': '''
500 gram dana kuşbaşı et
1 adet büyük kuru soğan
2 adet yeşil biber
1 adet kırmızı kapya biber
2 adet domates
2 diş sarımsak
3 yemek kaşığı sıvı yağ
1 tatlı kaşığı tuz
1 çay kaşığı karabiber
1 çay kaşığı kekik
''',
        'instructions': '''

1. Geniş bir tavayı yüksek ateşte iyice ısıtın.

2. Dana etlerini tavaya alın.

3. Et suyunu salıp çekene kadar kavurun.

4. Sıvı yağı ilave edin.

5. Yemeklik doğranmış soğanları ekleyin.

6. İnce doğranmış sarımsakları ilave edin.

7. Yeşil ve kırmızı biberleri ekleyin.

8. Sebzeler hafif yumuşayana kadar soteleyin.

9. Küp doğranmış domatesleri tavaya ekleyin.

10. Tuz, karabiber ve kekiği ilave edin.

11. Kapağını kapatıp kısık ateşte 15 dakika pişirin.

12. Etler tamamen yumuşayınca ocaktan alın.

13. Sıcak olarak servis edin.
    ''',
        'image': 'et_sote',
        'prep_time': '50 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Orta',
      },

      {
        'category_id': anaYemekId,
        'name': 'Lahmacun',
        'description':
            'İncecik hamur üzerinde baharatlı kıymalı harcıyla hazırlanan eşsiz Anadolu lezzeti.',
        'ingredients': '''
Hamur İçin:
4 su bardağı un
1 paket instant maya
1 tatlı kaşığı tuz
1 su bardağı ılık su

Harcı İçin:
300 gram dana kıyma
1 adet kuru soğan
2 adet domates
2 adet yeşil biber
Yarım demet maydanoz
1 yemek kaşığı domates salçası
1 çay kaşığı pul biber
1 çay kaşığı tuz
''',
        'instructions': '''

1. Hamur malzemelerini yoğurup ele yapışmayan bir hamur hazırlayın.

2. Hamuru üzeri kapalı şekilde mayalanmaya bırakın.

3. Soğan, domates, biber ve maydanozu rondodan geçirin.

4. Sebzeleri kıyma ile karıştırın.

5. Salça ve baharatları ilave edin.

6. Harcı homojen hale gelene kadar karıştırın.

7. Mayalanan hamuru bezelere ayırın.

8. Her bezeyi ince şekilde açın.

9. Hazırladığınız harcı hamurların üzerine yayın.

10. Önceden ısıtılmış 230 derece fırına verin.

11. Lahmacunların kenarları kızarana kadar pişirin.

12. Limon ve maydanoz ile servis edin.
    ''',
        'image': 'lahmacun',
        'prep_time': '60 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Orta',
      },

      {
        'category_id': anaYemekId,
        'name': 'Mantı',
        'description':
            'Sarımsaklı yoğurt ve tereyağlı sos ile servis edilen Kayseri usulü geleneksel mantı.',
        'ingredients': '''
Hamur İçin:
4 su bardağı un
1 adet yumurta
1 su bardağı su
1 tatlı kaşığı tuz

İç Harcı:
250 gram dana kıyma
1 adet kuru soğan
1 çay kaşığı tuz
1 çay kaşığı karabiber

Üzeri İçin:
2 su bardağı yoğurt
2 diş sarımsak
2 yemek kaşığı tereyağı
1 tatlı kaşığı kırmızı toz biber
''',
        'instructions': '''

1. Un, yumurta, su ve tuz ile sert bir hamur yoğurun.

2. Hamuru 30 dakika dinlendirin.

3. Kıyma, rendelenmiş soğan ve baharatları karıştırın.

4. Hamuru ince şekilde açın.

5. Küçük kareler halinde kesin.

6. Her karenin ortasına kıymalı harç koyun.

7. Mantıları bohça şeklinde kapatın.

8. Büyük bir tencerede su kaynatın.

9. Mantıları kaynar suda 12-15 dakika haşlayın.

10. Yoğurt ve sarımsağı karıştırın.

11. Mantıları servis tabağına alın.

12. Üzerine sarımsaklı yoğurt dökün.

13. Tereyağında kırmızı biberi kavurun.

14. Sosu mantının üzerine gezdirerek servis edin.
    ''',
        'image': 'manti',
        'prep_time': '120 dk',
        'servings': '5 Kişilik',
        'difficulty': 'Zor',
      },

      {
        'category_id': anaYemekId,
        'name': 'İzmir Köfte',
        'description':
            'Patates, köfte ve domates sosunun fırında buluştuğu klasik ev yemeği.',
        'ingredients': '''
400 gram dana kıyma
1 adet kuru soğan
1 adet yumurta
3 yemek kaşığı galeta unu
4 adet patates
2 adet yeşil biber
2 adet domates

Sos İçin:
1 yemek kaşığı domates salçası
1 su bardağı sıcak su
1 tatlı kaşığı tuz
''',
        'instructions': '''

1. Kıyma, rendelenmiş soğan, yumurta og galeta ununu karıştırın.

2. Harçtan uzun köfteler hazırlayın.

3. Patatesleri dilimleyin.

4. Patatesleri hafifçe kızartın.

5. Köfteleri tavada mühürleyin.

6. Fırın tepsisine patatesleri dizin.

7. Köfteleri patateslerin üzerine yerleştirin.

8. Biber ve domatesleri ekleyin.

9. Salça, sıcak su ve tuzu karıştırarak sos hazırlayın.

10. Sosu tepsinin üzerine dökün.

11. Önceden ısıtılmış 190 derece fırında pişirin.

12. Köfteler tamamen kızarana kadar yaklaşık 35 dakika pişirin.

13. Sıcak olarak servis edin.
    ''',
        'image': 'izmir_kofte',
        'prep_time': '70 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Orta',
      },
    ];

    // ==========================================
    // 3. TATLILAR (5 TARİF)
    // ==========================================
    List<Map<String, dynamic>> tatlilar = [
      {
        'category_id': tatliId,
        'name': 'Fırın Sütlaç',
        'description':
            'Üzeri nar gibi kızarmış, kıvamı tam yerinde geleneksel Türk sütlü tatlısı.',
        'ingredients': '''
1 litre süt
1 çay bardağı pirinç
1,5 su bardağı su
1 su bardağı toz şeker
2 yemek kaşığı nişasta
Yarım çay bardağı su

Üzeri İçin:
Tarçın (isteğe bağlı)
''',
        'instructions': '''

1. Pirinci yıkayıp su ile birlikte tencereye alın.

2. Pirinçler yumuşayana kadar haşlayın.

3. Sütü ilave ederek kaynamaya bırakın.

4. Şekeri ekleyip karıştırın.

5. Nişastayı yarım çay bardağı suda açın.

6. Nişastalı karışımı yavaş yavaş sütlaca ekleyin.

7. Sürekli karıştırarak koyulaşmasını sağlayın.

8. Karışımı güveç kaplarına paylaştırın.

9. Kapları fırın tepsisine dizin.

10. Tepsiye sıcak su ekleyin.

11. Önceden ısıtılmış 220 derece fırının üst rafında üzerleri kızarana kadar pişirin.

12. Oda sıcaklığına geldikten sonra buzdolabında dinlendirin.

13. Soğuk servis edin.
    ''',
        'image': 'sutlac',
        'prep_time': '50 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': tatliId,
        'name': 'Brownie',
        'description':
            'Yoğun çikolata aroması ve yumuşacık dokusuyla gerçek brownie lezzeti.',
        'ingredients': '''
200 gram bitter çikolata
150 gram tereyağı
3 adet yumurta
1 su bardağı toz şeker
1 su bardağı un
2 yemek kaşığı kakao
1 paket vanilin
Bir tutam tuz
''',
        'instructions': '''

1. Bitter çikolata ve tereyağını benmari usulü eritin.

2. Yumurtaları ve şekeri köpük köpük olana kadar çırpın.

3. Eritilmiş çikolatalı karışımı ilave edin.

4. Vanilin ve tuzu ekleyin.

5. Un ve kakaoyu eleyerek karışıma katın.

6. Spatula yardımıyla homojen hale getirin.

7. Yağlanmış kare kalıba harcı dökün.

8. Önceden ısıtılmış 170 derece fırında pişirin.

9. İçinin hafif nemli kalmasına dikkat edin.

10. Fırından çıkarıp tamamen soğutun.

11. Kare dilimler halinde keserek servis edin.
    ''',
        'image': 'brownie',
        'prep_time': '45 dk',
        'servings': '8 Kişilik',
        'difficulty': 'Orta',
      },

      {
        'category_id': tatliId,
        'name': 'Cheesecake',
        'description':
            'Kremamsı dokusu ve bisküvi tabanıyla dünyanın en sevilen tatlılarından biri.',
        'ingredients': '''
Tabanı İçin:
2 paket yulaflı bisküvi
100 gram tereyağı

Kreması İçin:
600 gram labne peyniri
200 ml sıvı krema
3 adet yumurta
1 su bardağı toz şeker
1 adet limon kabuğu rendesi
1 yemek kaşığı limon suyu

Sosu İçin:
Orman meyveli sos veya çilek sosu
''',
        'instructions': '''

1. Bisküvileri rondodan geçirerek un haline getirin.

2. Eritilmiş tereyağı ile karıştırın.

3. Karışımı kelepçeli kalıbın tabanına bastırarak yayın.

4. Labne, krema ve şekeri çırpın.

5. Yumurtaları tek tek ekleyin.

6. Limon suyu ve limon kabuğunu ilave edin.

7. Hazırladığınız kremayı tabanın üzerine dökün.

8. Önceden ısıtılmış 160 derece fırında pişirin.

9. Fırını kapatıp kapağını hafif aralayarak dinlendirin.

10. Tamamen soğuduktan sonra buzdolabında en az 4 saat bekletin.

11. Üzerine meyve sosu dökerek servis edin.
    ''',
        'image': 'cheesecake',
        'prep_time': '5 Saat',
        'servings': '8 Kişilik',
        'difficulty': 'Orta',
      },

      {
        'category_id': tatliId,
        'name': 'Mozaik Pasta',
        'description':
            'Pişirme gerektirmeyen, çikolata ve bisküvinin mükemmel uyumunu sunan nostaljik tatlı.',
        'ingredients': '''
2 paket pötibör bisküvi
125 gram tereyağı
1 çay bardağı süt
3 yemek kaşığı kakao
1 çay bardağı toz şeker

Üzeri İçin:
Hindistan cevizi veya çikolata sosu
''',
        'instructions': '''

1. Tereyağını küçük bir tencerede eritin.

2. Süt, kakao ve şekeri ekleyerek karıştırın.

3. Şeker tamamen eriyene kadar pişirin.

4. Bisküvileri elinizle iri parçalar halinde kırın.

5. Hazırladığınız sosu bisküvilerin üzerine dökün.

6. Tüm malzemeleri nazikçe karıştırın.

7. Karışımı streç film üzerine alın.

8. Rulo şekli vererek sıkıca sarın.

9. Dondurucuda en az 3 saat bekletin.

10. Dilimleyerek servis edin.
    ''',
        'image': 'mozaik_pasta',
        'prep_time': '3 Saat 15 dk',
        'servings': '8 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': tatliId,
        'name': 'Tiramisu',
        'description':
            'Kahve ve mascarpone aromalarının buluştuğu meşhur İtalyan tatlısı.',
        'ingredients': '''
1 paket kedidili bisküvi
2 su bardağı süt
200 gram labne peyniri
1 paket sıvı krema
1 çay bardağı toz şeker
2 yemek kaşığı granül kahve
1 su bardağı sıcak su

Üzeri İçin:
Kakao
''',
        'instructions': '''

1. Granül kahveyi sıcak suda çözün.

2. Kedidili bisküvileri kahveli karışıma kısa süre batırın.

3. Bisküvileri servis kabının tabanına dizin.

4. Labne, krema ve şekeri çırpın.

5. Pürüzsüz kıvam elde edene kadar karıştırın.

6. Kremanın yarısını bisküvilerin üzerine yayın.

7. İkinci kat bisküvileri dizin.

8. Kalan kremayı üzerine yayın.

9. Üzerini spatula ile düzeltin.

10. Buzdolabında en az 4 saat dinlendirin.

11. Servis öncesi bol kakao eleyin.

12. Soğuk servis edin.
    ''',
        'image': 'tiramisu',
        'prep_time': '4 Saat 30 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Kolay',
      },
    ];

    // ==========================================
    // 4. KAHVALTILIKLAR (5 TARİF)
    // ==========================================
    List<Map<String, dynamic>> kahvaltiliklar = [
      {
        'category_id': kahvaltiId,
        'name': 'Menemen',
        'description':
            'Taze domates ve biberlerle hazırlanan, ekmek banmalık klasik Türk kahvaltısı.',
        'ingredients': '''
3 adet yumurta
2 adet orta boy domates
2 adet yeşil biber
2 yemek kaşığı sıvı yağ
1 çay kaşığı tuz
Yarım çay kaşığı karabiber

İsteğe Bağlı:
Beyaz peynir veya kaşar peyniri
''',
        'instructions': '''
1. Domateslerin kabuklarını soyup küçük küpler halinde doğrayın.

2. Biberleri ince ince doğrayın.

3. Tavaya sıvı yağı alın ve biberleri kavurun.

4. Biberler yumuşayınca domatesleri ekleyin.

5. Domatesler suyunu çekene kadar pişirin.

6. Tuz ve karabiberi ilave edin.

7. Yumurtaları doğrudan tavaya kırın.

8. Yumurtaları isteğe göre karıştırarak pişirin.

9. Çok kurutmadan ocaktan alın.

10. Sıcak olarak servis edin.
''',
        'image': 'menemen',
        'prep_time': '20 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': kahvaltiId,
        'name': 'Pankek',
        'description':
            'Yumuşacık dokusuyla kahvaltı sofralarının en sevilen tatlı lezzeti.',
        'ingredients': '''
2 adet yumurta
1 su bardağı süt
1,5 su bardağı un
2 yemek kaşığı toz şeker
1 paket kabartma tozu
1 paket vanilin
1 yemek kaşığı sıvı yağ

Servis İçin:
Bal
Çikolata kreması
Meyve dilimleri
''',
        'instructions': '''
1. Yumurtaları ve şekeri çırpın.

2. Sütü ve sıvı yağı ekleyin.

3. Un, vanilin ve kabartma tozunu ilave edin.

4. Pürüzsüz kıvam elde edene kadar karıştırın.

5. Yapışmaz tavayı hafifçe ısıtın.

6. Harçtan küçük kepçeler halinde tavaya dökün.

7. Üzerinde kabarcıklar oluşunca ters çevirin.

8. Her iki tarafı altın rengini alana kadar pişirin.

9. Tüm harç bitene kadar işlemi tekrarlayın.

10. Bal veya çikolata kreması ile servis edin.
''',
        'image': 'pankek',
        'prep_time': '20 dk',
        'servings': '3 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': kahvaltiId,
        'name': 'Omlet',
        'description':
            'Peynir ve sebzelerle zenginleştirilmiş pratik ve doyurucu kahvaltılık.',
        'ingredients': '''
3 adet yumurta
50 gram rendelenmiş kaşar peyniri
1 adet yeşil biber
1 adet küçük domates
1 yemek kaşığı tereyağı
1 çay kaşığı tuz
Yarım çay kaşığı karabiber
''',
        'instructions': '''
1. Yumurtaları bir kaba kırın.

2. Tuz ve karabiber ekleyip çırpın.

3. Biber ve domatesi küçük küpler halinde doğrayın.

4. Tavada tereyağını eritin.

5. Sebzeleri birkaç dakika soteleyin.

6. Çırpılmış yumurtaları tavaya dökün.

7. Hafifçe karıştırarak pişirin.

8. Kaşar peynirini üzerine serpin.

9. Omleti ikiye katlayın.

10. Peynir eriyince sıcak servis edin.
''',
        'image': 'omlet',
        'prep_time': '15 dk',
        'servings': '1 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': kahvaltiId,
        'name': 'Gözleme',
        'description':
            'Bol peynirli iç harcıyla hazırlanan, tavada pişen geleneksel ev lezzeti.',
        'ingredients': '''
2 adet hazır yufka
150 gram beyaz peynir
Yarım demet maydanoz
1 yemek kaşığı tereyağı

Pişirmek İçin:
Tereyağı veya sıvı yağ
''',
        'instructions': '''
1. Beyaz peyniri çatalla ezin.

2. Maydanozu ince ince doğrayın.

3. Peynir ve maydanozu karıştırarak iç harcı hazırlayın.

4. Yufkaları tezgaha serin.

5. Harcı yufkanın yarısına yayın.

6. Yufkayı kapatarak yarım ay şekli verin.

7. Tavayı orta ateşte ısıtın.

8. Gözlemeleri tavaya alın.

9. Her iki tarafını da kızarana kadar pişirin.

10. Üzerine tereyağı sürün.

11. Dilimleyerek sıcak servis edin.
''',
        'image': 'gözleme',
        'prep_time': '25 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Kolay',
      },

      {
        'category_id': kahvaltiId,
        'name': 'Fransız Tostu',
        'description':
            'Tarçın ve vanilya aromasıyla hazırlanan, dışı çıtır içi yumuşak kahvaltılık.',
        'ingredients': '''
4 dilim tost ekmeği
2 adet yumurta
Yarım su bardağı süt
1 çay kaşığı tarçın
1 paket vanilin
1 yemek kaşığı tereyağı

Servis İçin:
Bal
Pudra şekeri
Taze meyveler
''',
        'instructions': '''
1. Yumurtaları bir kaba kırın.

2. Süt, tarçın ve vanilini ekleyin.

3. Karışımı iyice çırpın.

4. Ekmek dilimlerini hazırladığınız karışıma batırın.

5. Tavada tereyağını eritin.

6. Ekmekleri tavaya yerleştirin.

7. Her iki tarafı altın rengini alana kadar pişirin.

8. Servis tabağına alın.

9. Üzerine pudra şekeri serpin.

10. Bal ve meyvelerle servis edin.
''',
        'image': 'french_toast',
        'prep_time': '15 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Kolay',
      },
    ];

    // ==========================================
    // 5. SALATALAR (10 TARİF)
    // ==========================================
    List<Map<String, dynamic>> salatalar = [
      {
        'category_id': salataId,
        'name': 'Çoban Salata',
        'description': 'Yaz sofralarının vazgeçilmez ferah salatası.',
        'ingredients': 'Domates, Salatalık, Soğan, Maydanoz, Zeytinyağı, Limon',
        'instructions':
            'Tüm malzemeleri küçük doğrayın. Sos ile karıştırıp servis edin.',
        'image': 'coban_salata',
        'prep_time': '15 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Sezar Salata',
        'description': 'Tavuklu ve krutonlu dünyaca ünlü salata.',
        'ingredients': 'Marul, Tavuk, Kruton, Parmesan, Sezar sos',
        'instructions':
            'Tavukları pişirin. Malzemeleri karıştırıp sos ekleyin.',
        'image': 'sezar_salata',
        'prep_time': '30 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Orta',
      },
      {
        'category_id': salataId,
        'name': 'Akdeniz Salata',
        'description': 'Zeytin ve peynirle zenginleşen Akdeniz lezzeti.',
        'ingredients': 'Domates, Salatalık, Beyaz Peynir, Zeytin',
        'instructions': 'Malzemeleri doğrayıp karıştırın.',
        'image': 'akdeniz_salata',
        'prep_time': '15 dk',
        'servings': '3 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Kısır',
        'description': 'Bulgurun en sevilen hali.',
        'ingredients': 'İnce Bulgur, Domates Salçası, Maydanoz',
        'instructions': 'Bulguru şişirip diğer malzemelerle karıştırın.',
        'image': 'kisir',
        'prep_time': '35 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Orta',
      },
      {
        'category_id': salataId,
        'name': 'Patates Salatası',
        'description': 'Çay saatlerinin vazgeçilmezi.',
        'ingredients': 'Patates, Soğan, Maydanoz, Limon',
        'instructions': 'Patatesleri haşlayıp doğrayın. Karıştırın.',
        'image': 'patates_salata',
        'prep_time': '40 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Ton Balıklı Salata',
        'description': 'Protein açısından zengin hafif öğün.',
        'ingredients': 'Ton Balığı, Marul, Mısır, Domates',
        'instructions': 'Tüm malzemeleri karıştırıp servis edin.',
        'image': 'coban_salata',
        'prep_time': '15 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Roka Salatası',
        'description': 'Et yemeklerinin yanına mükemmel eşlikçi.',
        'ingredients': 'Roka, Domates, Nar Ekşisi',
        'instructions': 'Malzemeleri harmanlayın.',
        'image': 'akdeniz_salata',
        'prep_time': '10 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Gavurdağı Salatası',
        'description': 'Cevizli ve nar ekşili Antep usulü salata.',
        'ingredients': 'Domates, Soğan, Ceviz, Nar Ekşisi',
        'instructions': 'Doğrayıp sosla karıştırın.',
        'image': 'gavur',
        'prep_time': '20 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Makarna Salatası',
        'description': 'Doyurucu ve pratik salata çeşidi.',
        'ingredients': 'Makarna, Yoğurt, Mısır',
        'instructions': 'Makarnayı haşlayıp diğer malzemelerle karıştırın.',
        'image': 'makarnasalata',
        'prep_time': '25 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': salataId,
        'name': 'Yeşil Salata',
        'description': 'Her sofraya uyum sağlayan klasik salata.',
        'ingredients': 'Marul, Salatalık, Limon',
        'instructions': 'Doğrayıp servis edin.',
        'image': 'yesilsalata',
        'prep_time': '10 dk',
        'servings': '2 Kişilik',
        'difficulty': 'Kolay',
      },
    ];

    // ==========================================
    // 6. HAMUR İŞLERİ (5 TARİF)
    // ==========================================
    List<Map<String, dynamic>> hamurIsleri = [
      {
        'category_id': hamurisiId,
        'name': 'Poğaça',
        'description':
            'Yumuşacık dokusu ve peynirli iç harcıyla çay saatlerinin vazgeçilmezi.',
        'ingredients':
            '5 su bardağı un, 1 su bardağı ılık süt, 1 çay bardağı sıvı yağ, 1 paket instant maya, 1 yemek kaşığı şeker, 1 tatlı kaşığı tuz, Beyaz peynir, Maydanoz, 1 yumurta sarısı',
        'instructions':
            'Ilık süt, maya ve şekeri karıştırıp 5 dakika bekletin. Unu geniş bir kaba alın ve tuzu ekleyin. Maya karışımını ve sıvı yağı ilave ederek yumuşak bir hamur yoğurun. Hamuru üzeri kapalı şekilde yaklaşık 45 dakika mayalandırın. Hamurdan mandalina büyüklüğünde parçalar koparın. İçlerine ezilmiş beyaz peynir ve ince kıyılmış maydanoz koyup kapatın. Tepsiye dizin, üzerine yumurta sarısı sürün. Önceden ısıtılmış 180 derece fırında yaklaşık 25 dakika üzeri kızarana kadar pişirin.',
        'image': 'pogaca',
        'prep_time': '90 dk',
        'servings': '8 Kişilik',
        'difficulty': 'Kolay',
      },
      {
        'category_id': hamurisiId,
        'name': 'Açma',
        'description':
            'Pastane usulü, yumuşak ve tereyağı aromalı açma tarifi.',
        'ingredients':
            '5 su bardağı un, 1 su bardağı süt, 1 çay bardağı sıvı yağ, 1 paket maya, 1 yumurta, 2 yemek kaşığı şeker, 1 tatlı kaşığı tuz, Tereyağı',
        'instructions':
            'Sütü hafif ılıtın ve maya ile şekeri içinde eritin. Un, yumurta, sıvı yağ ve tuz ile birlikte yoğurun. Hamur ele yapışmayan kıvama geldiğinde 1 saat mayalandırın. Hamurdan parçalar koparıp uzun şeritler halinde açın. Üzerlerine eritilmiş tereyağı sürüp rulo yapın ve açma şekli verin. Tepsi mayası için 20 dakika bekletin. Üzerine yumurta sarısı sürerek 180 derece fırında yaklaşık 25 dakika pişirin.',
        'image': 'acma',
        'prep_time': '100 dk',
        'servings': '8 Kişilik',
        'difficulty': 'Orta',
      },
      {
        'category_id': hamurisiId,
        'name': 'Su Böreği',
        'description':
            'Kat kat hamuru ve bol peynirli iç harcıyla geleneksel lezzet.',
        'ingredients':
            '6 adet yufka veya el açması hamur, Beyaz peynir, Maydanoz, 150 gr tereyağı, 2 yumurta',
        'instructions':
            'Peyniri ezip maydanozla karıştırın. Büyük bir tencerede su kaynatın ve hamurları tek tek kısa süre haşlayıp soğuk suya alın. Tepsiyi yağlayın. Katlar arasına eritilmiş tereyağı sürerek hamurları yerleştirin. Ortasına peynirli harcı yayın. Kalan hamurları aynı şekilde dizin. Üzerine yumurta sarısı sürün. 190 derece fırında yaklaşık 40 dakika altın rengini alana kadar pişirin.',
        'image': 'su_boregi',
        'prep_time': '120 dk',
        'servings': '8 Kişilik',
        'difficulty': 'Zor',
      },
      {
        'category_id': hamurisiId,
        'name': 'Pizza',
        'description':
            'Ev yapımı hamur ve bol malzemeyle hazırlanan İtalyan klasiği.',
        'ingredients':
            '4 su bardağı un, 1 paket maya, Domates sosu, Kaşar peyniri, Sucuk, Mantar, Zeytin',
        'instructions':
            'Maya, un ve su ile yumuşak bir hamur hazırlayın. Hamuru yaklaşık 1 saat mayalandırın. Hamuru açıp pizza tepsisine yerleştirin. Üzerine domates sosunu yayın. Kaşar peyniri ve tercih edilen malzemeleri ekleyin. Önceden ısıtılmış 220 derece fırında yaklaşık 15 dakika pişirin. Fırından çıkarıp sıcak servis edin.',
        'image': 'pizza',
        'prep_time': '80 dk',
        'servings': '4 Kişilik',
        'difficulty': 'Orta',
      },
      {
        'category_id': hamurisiId,
        'name': 'Kaşarlı Börek',
        'description': 'Dışı çıtır, içi uzayan kaşar peyniriyle nefis börek.',
        'ingredients':
            '3 adet yufka, Kaşar peyniri, 1 yumurta, 1 çay bardağı süt, Yarım çay bardağı sıvı yağ',
        'instructions':
            'Süt, yumurta ve sıvı yağı karıştırın. İlk yufkayı serip sostan sürün. Kaşar peynirini serpiştirin. Kat kat aynı işlemi uygulayın. Böreği dilimleyin. Üzerine kalan sostan sürün. 180 derece fırında yaklaşık 35 dakika pişirin.',
        'image': 'kasarliborek',
        'prep_time': '45 dk',
        'servings': '6 Kişilik',
        'difficulty': 'Kolay',
      },
    ];

    for (var r in corbalar) {
      await db.insert('recipes', r);
    }
    for (var r in anaYemekler) {
      await db.insert('recipes', r);
    }
    for (var r in tatlilar) {
      await db.insert('recipes', r);
    }
    for (var r in kahvaltiliklar) {
      await db.insert('recipes', r);
    }
    for (var r in salatalar) {
      await db.insert('recipes', r);
    }

    for (var r in hamurIsleri) {
      await db.insert('recipes', r);
    }
  }

  // ==========================================
  // CRUD METOTLARI
  // ==========================================

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await instance.database;
    return await db.query('recipes');
  }

  Future<List<Map<String, dynamic>>> getRecipesByCategory(
    int categoryId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'recipes',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<int> addFavorite(int recipeId) async {
    final db = await instance.database;
    return await db.insert('favorites', {
      'recipe_id': recipeId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> removeFavorite(int recipeId) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;
    return await db.rawQuery(
      'SELECT recipes.* FROM recipes INNER JOIN favorites ON recipes.id = favorites.recipe_id',
    );
  }

  Future<bool> isFavorite(int recipeId) async {
    final db = await instance.database;
    final maps = await db.query(
      'favorites',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return maps.isNotEmpty;
  }

  Future<int> addShoppingItem(String name) async {
    final db = await instance.database;
    return await db.insert('shopping_list', {
      'ingredient_name': name,
      'is_completed': 0,
    });
  }

  Future<int> toggleShoppingItem(int id, int isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'shopping_list',
      {'is_completed': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteShoppingItem(int id) async {
    final db = await instance.database;
    return await db.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getShoppingList() async {
    final db = await instance.database;
    return await db.query(
      'shopping_list',
      orderBy: 'is_completed ASC, id DESC',
    );
  }

  Future<int> addToMenu(int recipeId) async {
    final db = await instance.database;
    return await db.insert('my_menu', {
      'recipe_id': recipeId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> toggleMenuItem(int id, int isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'my_menu',
      {'is_completed': isCompleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeFromMenu(int id) async {
    final db = await instance.database;
    return await db.delete('my_menu', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMyMenu() async {
    final db = await instance.database;
    return await db.rawQuery(
      'SELECT my_menu.id as menu_entry_id, my_menu.is_completed, recipes.* FROM recipes INNER JOIN my_menu ON recipes.id = my_menu.recipe_id',
    );
  }

  Future<int> insertUserRecipe(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('user_recipes', row);
  }

  Future<List<Map<String, dynamic>>> getUserRecipes() async {
    final db = await instance.database;
    return await db.query('user_recipes', orderBy: 'id DESC');
  }

  Future<int> updateUserRecipe(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'user_recipes',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUserRecipe(int id) async {
    final db = await instance.database;
    return await db.delete('user_recipes', where: 'id = ?', whereArgs: [id]);
  }
}
