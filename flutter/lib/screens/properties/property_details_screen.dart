import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/image_gallery_viewer.dart';
import 'add_edit_property_screen.dart';

import '../../core/services/pdf_share_service.dart';

/// Property Details Screen
/// DHOLERA REAL ESTATE
class PropertyDetailsScreen extends StatefulWidget {
  final int propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PropertyService _propertyService = PropertyService();
  PropertyModel? _property;
  bool _isLoading = true;
  String? _errorMessage;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final property = await _propertyService.fetchPropertyDetails(widget.propertyId);
      if (mounted) {
        setState(() {
          _property = property;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openGallery(int index) {
    if (_property == null || _property!.images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageGalleryViewer(
          images: _property!.images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = Provider.of<AuthProvider>(context).isSuperAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Property Details', style: AppStyles.heading3.copyWith(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_property != null)
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF25D366)),
              tooltip: 'Share Brochure on WhatsApp',
              onPressed: () => PdfShareService.sharePropertyPdf(context, _property!),
            ),
          if (isSuperAdmin && _property != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Property',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddEditPropertyScreen(property: _property)),
                );
                _loadPropertyDetails();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              tooltip: 'Delete Property',
              onPressed: () async {
                final confirm = await UiHelpers.showConfirmDialog(
                  context,
                  title: 'Delete Property',
                  message: 'Are you sure you want to delete this property?',
                );
                if (confirm && context.mounted) {
                  final ok = await Provider.of<PropertyProvider>(context, listen: false).deleteProperty(_property!.id);
                  if (context.mounted) {
                    if (ok) {
                      UiHelpers.showSnackBar(context, 'Property deleted');
                      Navigator.of(context).pop();
                    } else {
                      UiHelpers.showSnackBar(context, 'Delete failed', isError: true);
                    }
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading property details...')
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadPropertyDetails, child: const Text('Retry')),
                    ],
                  ),
                )
              : _property == null
                  ? const Center(child: Text('Property not found.'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Banner / Carousel Header
                          if (_property!.images.isNotEmpty) ...[
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                SizedBox(
                                  height: 260.0,
                                  child: PageView.builder(
                                    itemCount: _property!.images.length,
                                    onPageChanged: (idx) {
                                      setState(() {
                                        _activeImageIndex = idx;
                                      });
                                    },
                                    itemBuilder: (ctx, index) {
                                      final img = _property!.images[index];
                                      return GestureDetector(
                                        onTap: () => _openGallery(index),
                                        child: CachedNetworkImage(
                                          imageUrl: img.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[200],
                                            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(12.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Photo ${_activeImageIndex + 1} of ${_property!.images.length}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Thumbnail Strip Selector
                            if (_property!.images.length > 1)
                              Container(
                                height: 70.0,
                                color: Colors.black.withValues(alpha: 0.86),
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _property!.images.length,
                                  itemBuilder: (ctx, index) {
                                    final img = _property!.images[index];
                                    final isSelected = _activeImageIndex == index;
                                    return GestureDetector(
                                      onTap: () => _openGallery(index),
                                      child: Container(
                                        width: 70.0,
                                        margin: const EdgeInsets.only(right: 8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6.0),
                                          child: CachedNetworkImage(
                                            imageUrl: img.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ] else ...[
                            Container(
                              height: 180.0,
                              color: const Color(0xFFF0F4F8),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.landscape, size: 60, color: AppColors.textLight),
                                    SizedBox(height: 8),
                                    Text('No photos uploaded for this property listing.', style: TextStyle(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Main Property Specification Card
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(_property!.villageName, style: AppStyles.heading1),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Text(
                                        _property!.zone,
                                        style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),

                                // Area Display Highlight Box
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: const Icon(Icons.square_foot, color: AppColors.primary, size: 28),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('TOTAL AREA', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_property!.area.toStringAsFixed(_property!.area == _property!.area.roundToDouble() ? 0 : 2)} ${_property!.areaUnit}',
                                            style: AppStyles.heading2.copyWith(color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24.0),

                                Text('Property Specifications', style: AppStyles.heading3),
                                const SizedBox(height: 12.0),

                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildSpecRow('Survey Number', _property!.surveyNo, Icons.pin_drop_outlined),
                                      const Divider(height: 24.0, color: AppColors.border),
                                      _buildSpecRow('Zone', _property!.zone, Icons.map_outlined),
                                      const Divider(height: 24.0, color: AppColors.border),
                                      _buildSpecRow('Road', _property!.road, Icons.add_road_outlined),
                                      if (_property!.tp != null && _property!.tp!.isNotEmpty) ...[
                                        const Divider(height: 24.0, color: AppColors.border),
                                        _buildSpecRow('Town Planning (TP)', _property!.tp!, Icons.location_city_outlined),
                                      ],
                                      if (_property!.fp != null && _property!.fp!.isNotEmpty) ...[
                                        const Divider(height: 24.0, color: AppColors.border),
                                        _buildSpecRow('Final Plot No', _property!.fp!, Icons.nature_people_outlined),
                                      ],
                                      if (isSuperAdmin && _property!.landingPrice != null && _property!.landingPrice!.isNotEmpty) ...[
                                        const Divider(height: 24.0, color: AppColors.border),
                                        _buildSpecRow('Landing Price', _property!.landingPrice!, Icons.currency_rupee),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24.0),

                                // Reference Notes Box
                                if (_property!.reference != null && _property!.reference!.isNotEmpty) ...[
                                  Text('Reference & Agent Details', style: AppStyles.heading3),
                                  const SizedBox(height: 8.0),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9EC),
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(color: const Color(0xFFFFE0B2)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.bookmark, color: AppColors.warning, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _property!.reference!,
                                            style: AppStyles.bodyMedium.copyWith(color: const Color(0xFF5D4037)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24.0),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52.0,
                                  child: ElevatedButton.icon(
                                    onPressed: () => PdfShareService.sharePropertyPdf(context, _property!),
                                    icon: const Icon(Icons.share, color: Colors.white),
                                    label: const Text(
                                      'Share PDF Brochure',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSpecRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20.0, color: AppColors.textSecondary),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
