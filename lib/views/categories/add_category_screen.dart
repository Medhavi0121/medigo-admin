import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryProvider>();

    final model = CategoryModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      docCount: '0', // default for new category
    );

    await provider.addCategory(model);

    if (provider.error == null && mounted) {
      Helpers.showSnackBar(context, 'Category added successfully');
      context.go('/categories'); // redirect to categories list
    } else if (provider.error != null && mounted) {
      Helpers.showSnackBar(context, provider.error!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

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
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add Category',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Category Name *',
                          hint: 'e.g. Cardiology',
                          controller: _nameCtrl,
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Description',
                          hint: 'Brief description of this category',
                          controller: _descCtrl,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Image URL',
                          hint: 'https://example.com/image.png',
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
                              label: 'Add Category',
                              onPressed: _submit,
                              isLoading: provider.isLoading,
                              icon: Icons.add,
                            ),
                          ],
                        ),
                      ],
                    ),
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