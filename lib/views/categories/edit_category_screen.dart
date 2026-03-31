import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../common/topbar.dart';

class EditCategoryScreen extends StatefulWidget {
  final String categoryId;
  const EditCategoryScreen({super.key, required this.categoryId});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  bool _initialized = false;

  void _init(CategoryModel cat) {
    if (_initialized) return;
    _nameCtrl.text = cat.name;
    _descCtrl.text = cat.description;
    _imageCtrl.text = cat.imageUrl;
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(CategoryProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    await provider.updateCategory(widget.categoryId, {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'imageUrl': _imageCtrl.text.trim(),
    });
    if (provider.error == null && mounted) {
      Helpers.showSnackBar(context, 'Category updated successfully');
      context.go('/categories');
    } else if (provider.error != null && mounted) {
      Helpers.showSnackBar(context, provider.error!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final cat = provider.allCategories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () =>
          CategoryModel(id: widget.categoryId, name: '', description: '', imageUrl: '', docCount: '0'),
    );
    _init(cat);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () => context.go('/categories'),
                    icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                const Text('Edit Category',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ContentCard(
                title: 'Edit Category',
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Category Name *',
                        controller: _nameCtrl,
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Description',
                        controller: _descCtrl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Image URL',
                        controller: _imageCtrl,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlineButton(
                            label: 'Cancel',
                            onPressed: () => context.go('/categories'),
                          ),
                          const SizedBox(width: 12),
                          PrimaryButton(
                            label: 'Update Category',
                            onPressed: () => _submit(provider),
                            isLoading: provider.isLoading,
                            icon: Icons.save_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
