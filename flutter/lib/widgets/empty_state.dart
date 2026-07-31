import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Properties Found',
    this.message = 'Try adjusting your search query or clear filters to view available property listings.',
    this.icon = Icons.landscape_outlined,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4F8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56.0, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20.0),
            Text(title, style: AppStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8.0),
            Text(message, style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (onRefresh != null) ...[
              const SizedBox(height: 24.0),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh List'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
