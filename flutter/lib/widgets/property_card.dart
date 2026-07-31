import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final bool isSuperAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isSuperAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Thumbnail Stack
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: property.primaryImage != null && property.primaryImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: property.primaryImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFFF0F4F8),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFF0F4F8),
                                child: const Icon(Icons.landscape, size: 48, color: AppColors.textLight),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF0F4F8),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.landscape, size: 48, color: AppColors.textLight),
                                  SizedBox(height: 4),
                                  Text('No Photo Uploaded', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // Area Badge Overlay (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.square_foot, color: AppColors.primaryAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${property.area.toStringAsFixed(property.area == property.area.roundToDouble() ? 0 : 2)} ${property.areaUnit}',
                            style: const TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Image Count Badge (Top Right)
                  if (property.images.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${property.images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Property Card Body Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            property.villageName,
                            style: AppStyles.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            property.zone,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),

                    // Survey No & Road
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Survey No: ${property.surveyNo}',
                          style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.add_road, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.road,
                            style: AppStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // TP & FP tags if present
                    if ((property.tp != null && property.tp!.isNotEmpty) || (property.fp != null && property.fp!.isNotEmpty))
                      Wrap(
                        spacing: 8.0,
                        children: [
                          if (property.tp != null && property.tp!.isNotEmpty)
                            _buildInfoChip('TP: ${property.tp}'),
                          if (property.fp != null && property.fp!.isNotEmpty)
                            _buildInfoChip('FP: ${property.fp}'),
                        ],
                      ),

                    // Reference tag & Admin Controls
                    const Divider(height: 20.0, color: AppColors.border),
                    Row(
                      children: [
                        if (property.reference != null && property.reference!.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.bookmark_outline, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    property.reference!,
                                    style: AppStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),

                        // Super Admin Edit/Delete Action Icons
                        if (isSuperAdmin) ...[
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                            onPressed: onEdit,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6.0),
                            tooltip: 'Edit Property',
                          ),
                          const SizedBox(width: 8.0),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            onPressed: onDelete,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6.0),
                            tooltip: 'Delete Property',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.0, fontWeight: FontWeight.w500),
      ),
    );
  }
}
