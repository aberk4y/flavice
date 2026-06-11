import 'package:flutter/cupertino.dart';
import 'package:mealio/database/database_helper.dart';
import 'package:mealio/utils/app_colors.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? recipeToEdit;

  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _timeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _difficultyController = TextEditingController();

  bool get _isEditMode => widget.recipeToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.recipeToEdit!['name'];
      _descController.text = widget.recipeToEdit!['description'];
      _ingredientsController.text = widget.recipeToEdit!['ingredients'];
      _instructionsController.text = widget.recipeToEdit!['instructions'];
      _timeController.text = widget.recipeToEdit!['prep_time'];
      _servingsController.text = widget.recipeToEdit!['servings'];
      _difficultyController.text = widget.recipeToEdit!['difficulty'];
    } else {
      _timeController.text = "20 dk";
      _servingsController.text = "2 Kişilik";
      _difficultyController.text = "Kolay";
    }
  }

  Future<void> _saveRecipe() async {
    if (_nameController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _ingredientsController.text.trim().isEmpty ||
        _instructionsController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Eksik Alanlar Var'),
          content: const Text(
            'Lütfen başlık, açıklama, malzemeler ve hazırlanışı alanlarını boş bırakmayın.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Tamam'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final rowData = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'ingredients': _ingredientsController.text.trim(),
      'instructions': _instructionsController.text.trim(),
      'prep_time': _timeController.text.trim(),
      'servings': _servingsController.text.trim(),
      'difficulty': _difficultyController.text.trim(),
      'image': null,
    };

    final db = DatabaseHelper.instance;

    if (_isEditMode) {
      await db.updateUserRecipe(widget.recipeToEdit!['id'], rowData);
    } else {
      await db.insertUserRecipe(rowData);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditMode ? 'Tarifi Düzenle' : 'Yeni Tarif Ekle'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveRecipe,
          child: const Text(
            'Kaydet',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSection(
                'Tarif Adı',
                _nameController,
                'Örn: Pratik Menemen',
              ),
              _buildFormSection(
                'Kısa Açıklama',
                _descController,
                'Örn: Pazar sabahlarının vazgeçilmezi',
              ),
              _buildFormSection(
                'Malzemeler (Virgülle Ayırın)',
                _ingredientsController,
                'Örn: 2 yumurta, 1 domates, 1 biber',
              ),
              _buildFormSection(
                'Hazırlanışı (Noktayla Ayırın)',
                _instructionsController,
                'Örn: Biberleri soteleyin. Domatesi ekleyin. Yumurtayı kırın.',
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tarif Detayları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildFormSection(
                      'Süre',
                      _timeController,
                      'Örn: 15 dk',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormSection(
                      'Porsiyon',
                      _servingsController,
                      'Örn: 2 Kişilik',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormSection(
                      'Zorluk',
                      _difficultyController,
                      'Örn: Kolay',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _saveRecipe,
                  child: Text(
                    _isEditMode ? 'Değişiklikleri Kaydet' : 'Tarifi Yayınla',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.subText,
            ),
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            // HATA DÜZELTİLDİ: Parametreler BoxDecoration içine alındı
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            maxLines:
                label.contains('Malzemeler') || label.contains('Hazırlanışı')
                ? 3
                : 1,
            style: const TextStyle(color: AppColors.text, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
