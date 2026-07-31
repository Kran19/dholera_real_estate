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

  String _selectedAreaUnit = 'Sq Yard';
  final List<String> _areaUnitOptions = ['Sq Yard', 'Bigha'];

  final ImagePicker _picker = ImagePicker();
  final List<AppPickedImage> _newSelectedImages = [];
  final List<int> _deleteImageIds = [];
  List<PropertyImageModel> _existingImages = [];

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

    if (isEdit) {
      _selectedAreaUnit = widget.property!.areaUnit;
      _existingImages = List.from(widget.property!.images);
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
    super.dispose();
  }

  Future<void> _pickImages() async {
    final int currentTotal = _existingImages.length + _newSelectedImages.length;
    if (currentTotal >= 5) {
      if (mounted) UiHelpers.showSnackBar(context, 'Maximum limit of 5 photos reached.', isError: true);
      return;
    }

    final List<XFile> picked = await _picker.pickMultiImage(
      imageQuality: 85,
    );

    if (picked.isNotEmpty && mounted) {
      final int availableSlots = 5 - currentTotal;
      final List<XFile> toAdd = picked.take(availableSlots).toList();

      if (picked.length > availableSlots) {
        UiHelpers.showSnackBar(context, 'Only $availableSlots photo(s) added to stay within the 5-photo limit.');
      }

      for (var xFile in toAdd) {
        final bytes = await xFile.readAsBytes();
        _newSelectedImages.add(AppPickedImage(
          xfile: xFile,
          bytes: bytes,
          name: xFile.name,
        ));
      }

      if (mounted) setState(() {});
    }
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
        deleteImageIds: _deleteImageIds,
        newImages: _newSelectedImages,
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
        images: _newSelectedImages,
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

  @override
  Widget build(BuildContext context) {
    final int totalPhotos = _existingImages.length + _newSelectedImages.length;

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
              Text('Property Photographs (Max 5)', style: AppStyles.heading3),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$totalPhotos of 5 Selected', style: AppStyles.bodySmall),
                        if (totalPhotos < 5)
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_a_photo, size: 18, color: Colors.white),
                            label: const Text('Add Photos', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    if (totalPhotos == 0)
                      Container(
                        height: 100.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppColors.textLight, size: 36),
                              SizedBox(height: 4),
                              Text('No photos selected yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 100.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Render existing server images
                            ..._existingImages.map((img) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100.0,
                                    margin: const EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: img.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 14,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _deleteImageIds.add(img.id);
                                          _existingImages.removeWhere((item) => item.id == img.id);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            // Render newly picked memory images (Cross-Platform Web & Mobile)
                            ..._newSelectedImages.map((img) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100.0,
                                    margin: const EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(color: AppColors.primaryAccent, width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        img.bytes,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 14,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _newSelectedImages.remove(img);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
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
                label: 'Zone Designation *',
                hint: 'e.g. Residential, Commercial, Industrial',
                controller: _zoneController,
                prefixIcon: Icons.map_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Zone designation is required';
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
                label: 'Road Access / Width *',
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
                      label: 'Final Plot (FP)',
                      hint: 'e.g. FP-45',
                      controller: _fpController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              CustomTextField(
                label: 'Reference Notes',
                hint: 'e.g. Direct owner title clear property',
                controller: _referenceController,
                maxLines: 3,
                prefixIcon: Icons.bookmark_border_outlined,
              ),
              const SizedBox(height: 32.0),

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
