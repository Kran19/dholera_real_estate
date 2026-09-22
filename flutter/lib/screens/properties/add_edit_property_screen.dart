import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/property_model.dart';
import '../../models/property_image_model.dart';
import '../../models/app_picked_image.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Add / Edit Property Form Screen (Super Admin Only — Cross-Platform Web & Mobile)
/// DHOLERA REAL ESTATE
class AddEditPropertyScreen extends StatefulWidget {
  final PropertyModel? property;

  const AddEditPropertyScreen({super.key, this.property});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _villageController;
  late TextEditingController _surveyNoController;
  late TextEditingController _zoneController;
  late TextEditingController _tpController;
  late TextEditingController _fpController;
  late TextEditingController _roadController;
  late TextEditingController _areaController;
  late TextEditingController _referenceController;
  late TextEditingController _landingPriceController;

  String _selectedAreaUnit = 'Sq Yard';
  final List<String> _areaUnitOptions = ['Sq Yard', 'Bigha'];

  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _slots = List.filled(5, null); // 0: DP Map, 1: Open Plot, 2: NA Order, 3: Zoning1, 4: Zoning2
  final List<int> _deleteImageIds = [];

  bool _isSubmitting = false;

  bool get isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    _villageController = TextEditingController(text: widget.property?.villageName ?? '');
    _surveyNoController = TextEditingController(text: widget.property?.surveyNo ?? '');
    _zoneController = TextEditingController(text: widget.property?.zone ?? '');
    _tpController = TextEditingController(text: widget.property?.tp ?? '');
    _fpController = TextEditingController(text: widget.property?.fp ?? '');
    _roadController = TextEditingController(text: widget.property?.road ?? '');
    _areaController = TextEditingController(text: widget.property?.area != null ? widget.property!.area.toString() : '');
    _referenceController = TextEditingController(text: widget.property?.reference ?? '');
    _landingPriceController = TextEditingController(text: widget.property?.landingPrice ?? '');

    if (isEdit) {
      _selectedAreaUnit = widget.property!.areaUnit;
      for (var img in widget.property!.images) {
        if (img.sortOrder >= 1 && img.sortOrder <= 5) {
          _slots[img.sortOrder - 1] = img;
        }
      }
    }
  }

  @override
  void dispose() {
    _villageController.dispose();
    _surveyNoController.dispose();
    _zoneController.dispose();
    _tpController.dispose();
    _fpController.dispose();
    _roadController.dispose();
    _areaController.dispose();
    _referenceController.dispose();
    _landingPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      setState(() {
        final existing = _slots[index];
        if (existing is PropertyImageModel) {
          _deleteImageIds.add(existing.id);
        }
        _slots[index] = AppPickedImage(
          xfile: picked,
          bytes: bytes,
          name: picked.name,
        );
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      final existing = _slots[index];
      if (existing is PropertyImageModel) {
        _deleteImageIds.add(existing.id);
      }
      _slots[index] = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final double? areaVal = double.tryParse(_areaController.text.trim());
    if (areaVal == null || areaVal <= 0) {
      UiHelpers.showSnackBar(context, 'Please enter a valid numeric area.', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    bool success;
    final List<AppPickedImage> newImagesToSend = [];
    final List<String> sequence = [];
    for (int i = 0; i < 5; i++) {
      final item = _slots[i];
      if (item == null) {
        sequence.add('empty');
      } else if (item is PropertyImageModel) {
        sequence.add('existing_${item.id}');
      } else if (item is AppPickedImage) {
        sequence.add('new_${newImagesToSend.length}');
        newImagesToSend.add(item);
      }
    }
    final String imageSequenceStr = sequence.join(',');

    if (isEdit) {
      success = await propertyProvider.updateProperty(
        id: widget.property!.id,
        villageName: _villageController.text.trim(),
        surveyNo: _surveyNoController.text.trim(),
        zone: _zoneController.text.trim(),
        tp: _tpController.text.trim(),
        fp: _fpController.text.trim(),
        road: _roadController.text.trim(),
        area: areaVal,
        areaUnit: _selectedAreaUnit,
        reference: _referenceController.text.trim(),
        landingPrice: _landingPriceController.text.trim(),
        imageSequence: imageSequenceStr,
        deleteImageIds: _deleteImageIds,
        newImages: newImagesToSend,
      );
    } else {
      success = await propertyProvider.createProperty(
        villageName: _villageController.text.trim(),
        surveyNo: _surveyNoController.text.trim(),
        zone: _zoneController.text.trim(),
        tp: _tpController.text.trim(),
        fp: _fpController.text.trim(),
        road: _roadController.text.trim(),
        area: areaVal,
        areaUnit: _selectedAreaUnit,
        reference: _referenceController.text.trim(),
        landingPrice: _landingPriceController.text.trim(),
        imageSequence: imageSequenceStr,
        images: newImagesToSend,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      UiHelpers.showSnackBar(
        context,
        isEdit ? 'Property updated successfully!' : 'Property added successfully!',
      );
      Navigator.of(context).pop();
    } else {
      UiHelpers.showSnackBar(
        context,
        propertyProvider.errorMessage ?? 'Operation failed. Please try again.',
        isError: true,
      );
    }
  }

  final List<String> _slotTitles = [
    'DP Location Map',
    'Open Plot Map',
    'NA Order',
    'Zoning Certificate (1)',
    'Zoning Certificate (2)',
  ];

  Widget _buildImageSlot(int index) {
    final item = _slots[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_slotTitles[index], style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Container(
          height: 140.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          child: item == null
              ? Center(
                  child: InkWell(
                    onTap: () => _pickImage(index),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: AppColors.primary, size: 36),
                        SizedBox(height: 4),
                        Text('Tap to upload', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: item is PropertyImageModel
                          ? CachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover)
                          : Image.memory((item as AppPickedImage).bytes, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = Provider.of<AuthProvider>(context, listen: false).isSuperAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          isEdit ? 'Edit Property' : 'Add New Property',
          style: AppStyles.heading3.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Picker Card Section
              Text('Property Documents', style: AppStyles.heading3),
              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(5, (index) => _buildImageSlot(index)),
                ),
              ),
              const SizedBox(height: 24.0),

              // Form Specifications Section
              Text('Property Specifications', style: AppStyles.heading3),
              const SizedBox(height: 12.0),

              CustomTextField(
                label: 'Village Name *',
                hint: 'e.g. Kadipur, Valinda, Bhimtalav',
                controller: _villageController,
                prefixIcon: Icons.location_city_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Village name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              CustomTextField(
                label: 'Survey No *',
                hint: 'e.g. 104/A or 452',
                controller: _surveyNoController,
                prefixIcon: Icons.numbers_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Survey number is required';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              CustomTextField(
                label: 'Zone *',
                hint: 'e.g. Residential, Commercial, Industrial',
                controller: _zoneController,
                prefixIcon: Icons.map_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Zone is required';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'Area *',
                      hint: 'e.g. 500',
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.aspect_ratio_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Area is required';
                        if (double.tryParse(val.trim()) == null) return 'Enter a number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit *', style: AppStyles.labelStyle),
                        const SizedBox(height: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAreaUnit,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              items: _areaUnitOptions.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit, style: AppStyles.bodyMedium),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedAreaUnit = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              CustomTextField(
                label: 'Road *',
                hint: 'e.g. 24 Mtr, 55 Mtr DP Road',
                controller: _roadController,
                prefixIcon: Icons.add_road_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Road specification is required';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Town Planning (TP)',
                      hint: 'e.g. TP-1',
                      controller: _tpController,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: CustomTextField(
                      label: 'Final Plot No',
                      hint: 'e.g. FP-45',
                      controller: _fpController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              if (isSuperAdmin) ...[
                CustomTextField(
                  label: 'Landing Price',
                  hint: 'e.g. 15,00,000 or 1.5 Cr',
                  controller: _landingPriceController,
                  prefixIcon: Icons.currency_rupee,
                ),
                const SizedBox(height: 16.0),

                CustomTextField(
                  label: 'Reference Notes',
                  hint: 'e.g. Direct owner title clear property',
                  controller: _referenceController,
                  maxLines: 3,
                  prefixIcon: Icons.bookmark_border_outlined,
                ),
                const SizedBox(height: 16.0),
              ],

              CustomButton(
                text: isEdit ? 'Update Property Listing' : 'Submit Property',
                icon: Icons.cloud_upload_outlined,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
