import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/utils/app_colors.dart';
import 'package:mealio/utils/tab_controller.dart';
import 'package:mealio/widgets/shopping_tile.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Map<String, dynamic>> _shoppingList = [];
  bool _isLoading = true;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShoppingList();

    TabControllerManager.refreshShopping.addListener(() {
      if (mounted) {
        _loadShoppingList();
      }
    });
  }

  Future<void> _deleteAllItems() async {
    final db = DatabaseHelper.instance;
    for (final item in _shoppingList) {
      await db.deleteShoppingItem(item['id']);
    }
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final db = DatabaseHelper.instance;
    final data = await db.getShoppingList();
    if (mounted) {
      setState(() {
        _shoppingList = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _addItem() async {
    if (_textController.text.trim().isEmpty) return;

    final db = DatabaseHelper.instance;
    await db.addShoppingItem(_textController.text.trim());
    _textController.clear();
    _loadShoppingList();
  }

  Future<void> _toggleItem(int id, int currentStatus) async {
    final db = DatabaseHelper.instance;
    int newStatus = currentStatus == 1 ? 0 : 1;
    await db.toggleShoppingItem(id, newStatus);
    _loadShoppingList();
  }

  Future<void> _deleteItem(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteShoppingItem(id);
    _loadShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // DEĞİŞİKLİK: Çöp kutusunun "Listem" yazısıyla tam aynı hizada durması için kurgu güncellendi
                CupertinoSliverNavigationBar(
                  border: null,
                  backgroundColor: AppColors.background,
                  // largeTitle parametresini Row ile sararak çöp kutusunu tam başlığın yanına aldık
                  largeTitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Listem'),
                      Padding(
                        // Sağdan küçük bir boşluk bırakarak ekran kenarına yapışmasını önlüyoruz
                        padding: const EdgeInsets.only(right: 16.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 44, // iOS dokunma standart alanı
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text('Listeyi Temizle'),
                                content: const Text(
                                  'Tüm alışveriş listesini silmek istediğine emin misin?',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Vazgeç'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: const Text('Hepsini Sil'),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _deleteAllItems();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Icon(
                            CupertinoIcons.trash,
                            color: CupertinoColors.systemRed,
                            size: 24, // İdeal lüks çöp kutusu boyutu
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // MALZEME EKLEME ŞERİDİ
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _textController,
                            placeholder: 'Ekstra malzeme ekle...',
                            placeholderStyle: TextStyle(
                              color: AppColors.subText.withOpacity(0.4),
                              fontSize: 15,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.divider.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoButton(
                          color: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          borderRadius: BorderRadius.circular(14),
                          onPressed: _addItem,
                          child: const SizedBox(
                            height: 22,
                            child: Icon(
                              CupertinoIcons.add,
                              size: 22,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // LİSTE ALANI
                _shoppingList.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.shopping_cart,
                                size: 54,
                                color: AppColors.subText.withOpacity(0.35),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Alışveriş listeniz boş.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tarif detaylarından veya yukarıdan malzeme ekleyin.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = _shoppingList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: ShoppingTile(
                              name: item['ingredient_name'],
                              isCompleted: item['is_completed'] == 1,
                              onToggle: () =>
                                  _toggleItem(item['id'], item['is_completed']),
                              onDelete: () => _deleteItem(item['id']),
                            ),
                          );
                        }, childCount: _shoppingList.length),
                      ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
