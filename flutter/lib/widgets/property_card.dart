import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

/**
 * Responsive Property Card Component
 * DHOLERA REAL ESTATE — Optimized for 1-Col, 2-Col, and 4-Col Grid Layouts
 */
class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final bool isSuperAdmin;
  final bool isCompact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isSuperAdmin = false,
    this.isCompact = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double cardPadding = isCompact ? 10.0 : 16.0;
    final double titleFontSize = isCompact ? 13.5 : 16.0;
    final double imageHeight = isCompact ? 105.0 : 160.0;

    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 0 : 14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Property Thumbnail Container
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14.0)),
                    child: SizedBox(
                      height: imageHeight,
                      width: double.infinity,
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
                                child: const Icon(Icons.landscape, size: 36, color: AppColors.textLight),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF0F4F8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.landscape, size: isCompact ? 32 : 44, color: AppColors.textLight),
                                  const SizedBox(height: 4),
                                  Text(
                                    'No Photo Uploaded',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isCompact ? 10.5 : 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // Area Badge Overlay (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 7.0 : 10.0,
                        vertical: isCompact ? 3.0 : 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.square_foot, color: AppColors.primaryAccent, size: isCompact ? 12 : 14),
                          const SizedBox(width: 4),
                          Text(
                            '${property.area.toStringAsFixed(property.area == property.area.roundToDouble() ? 0 : 2)} ${property.areaUnit}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 10.5 : 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Image Count Badge (Top Right)
                  if (property.images.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library, color: Colors.white, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              '${property.images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Property Card Body
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Village Name & Zone Chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.villageName,
                            style: AppStyles.heading3.copyWith(fontSize: titleFontSize),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 6.0 : 8.0,
                            vertical: isCompact ? 2.0 : 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            property.zone,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: isCompact ? 9.5 : 11.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 4.0 : 6.0),

                    // Survey No & Road Info
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: isCompact ? 14 : 16, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Survey No: ${property.surveyNo}',
                            style: TextStyle(
                              fontSize: isCompact ? 11.0 : 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isCompact && property.road.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.add_road, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              property.road,
                              style: AppStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: isCompact ? 4.0 : 6.0),

                    // TP & FP tags
                    if ((property.tp != null && property.tp!.isNotEmpty) || (property.fp != null && property.fp!.isNotEmpty))
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: [
                          if (property.tp != null && property.tp!.isNotEmpty)
                            _buildInfoChip('TP: ${property.tp}', isCompact),
                          if (property.fp != null && property.fp!.isNotEmpty)
                            _buildInfoChip('FP: ${property.fp}', isCompact),
                        ],
                      ),

                    SizedBox(height: isCompact ? 6.0 : 10.0),

                    // Reference Notes & Admin Actions Bar
                    Row(
                      children: [
                        if (property.reference != null && property.reference!.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.bookmark_outline, size: isCompact ? 12 : 14, color: AppColors.textSecondary),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    property.reference!,
                                    style: TextStyle(
                                      fontSize: isCompact ? 10.0 : 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),

                        // Super Admin Action Icons (Edit & Delete)
                        if (isSuperAdmin) ...[
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.edit_outlined, size: isCompact ? 18 : 20, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.delete_outline, size: isCompact ? 18 : 20, color: AppColors.error),
                            ),
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

  Widget _buildInfoChip(String label, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6.0 : 8.0,
        vertical: isCompact ? 2.0 : 3.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: isCompact ? 10.0 : 11.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
