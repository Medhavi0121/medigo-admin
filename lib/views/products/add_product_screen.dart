import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../models/product_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../common/topbar.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _patientCountCtrl = TextEditingController(text: '0');
  final _experienceCtrl = TextEditingController(text: '0');

  String? _selectedCategoryId;
  bool _isActive = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    _patientCountCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      Helpers.showSnackBar(context, 'Please select a category', isError: true);
      return;
    }
    final provider = context.read<ProductProvider>();

    final model = ProductModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      categoryId: _selectedCategoryId!,
      imageUrls: _imageCtrl.text.trim().isNotEmpty ? [_imageCtrl.text.trim()] : [],
      patientCount: int.tryParse(_patientCountCtrl.text.trim()) ?? 0,
      dailyPatientCount: 0,
      experience: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
      rating: 0,
      reviewCount: 0,
      bookedCount: 0,
      status: _isActive,
      attributes: [],
    );

    await provider.addProduct(model);
    if (provider.error == null && mounted) {
      Helpers.showSnackBar(context, 'Doctor added successfully');
      context.go('/products');
    } else if (provider.error != null && mounted) {
      Helpers.showSnackBar(context, provider.error!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final catProvider = context.watch<CategoryProvider>();

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
                    onPressed: () => context.go('/products'),
                    icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                const Text('Add Doctor',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ContentCard(
                      title: 'Doctor Details',
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Doctor Name *',
                            hint: 'e.g. Dr. John Doe',
                            controller: _nameCtrl,
                            validator: Validators.required,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: 'About / Description',
                            hint: 'Experience, qualifications...',
                            controller: _descCtrl,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: 'Profile Image URL',
                            hint: 'https://example.com/doc.jpg',
                            controller: _imageCtrl,
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ContentCard(
                      title: 'Professional Info',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Consultation Fee *',
                                  hint: '0.00',
                                  controller: _priceCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: Validators.price,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                  prefix: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('\$', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  label: 'Experience (Years)',
                                  controller: _experienceCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Specialization / Category *',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: _selectedCategoryId,
                                      hint: const Text('Select a category'),
                                      validator: (v) => v == null ? 'Please select a category' : null,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      items: catProvider.allCategories
                                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                                          .toList(),
                                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  label: 'Total Patients Treated',
                                  controller: _patientCountCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text('Status (Active)',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const Spacer(),
                              Switch(
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlineButton(label: 'Cancel', onPressed: () => context.go('/products')),
                        const SizedBox(width: 12),
                        PrimaryButton(
                          label: 'Add Doctor',
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
          ],
        ),
      ),
    );
  }
}
