import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../network/api_client.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/**
 * In-App Version & Automatic Update Checker Service
 * DHOLERA REAL ESTATE
 */
class UpdateChecker {
  static final ApiClient _apiClient = ApiClient();

  /// Checks for available updates from Hostinger server
  static Future<void> checkForUpdates(BuildContext context, {bool showNoUpdateToast = false}) async {
    try {
      final response = await _apiClient.get(ApiConfig.versionConfig);
      final data = response['data'];
      if (data == null) return;

      final String latestVersion = data['latest_version'] ?? '1.0.0';
      final String apkUrl = data['apk_download_url'] ?? '';
      final String updateMessage = data['update_message'] ?? 'A new version of Dholera Real Estate is available!';
      final bool forceUpdate = data['force_update'] == true;

      if (_isVersionGreater(latestVersion, ApiConfig.currentAppVersion)) {
        if (!context.mounted) return;
        _showUpdateDialog(
          context: context,
          latestVersion: latestVersion,
          apkUrl: apkUrl,
          updateMessage: updateMessage,
          forceUpdate: forceUpdate,
        );
      } else if (showNoUpdateToast && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are using the latest version of Dholera Real Estate (v1.0.0).')),
        );
      }
    } catch (_) {
      // Silently ignore network errors during background update check
    }
  }

  /// Version comparison helper (e.g. "1.0.1" > "1.0.0")
  static bool _isVersionGreater(String newVersion, String currentVersion) {
    try {
      List<int> v1 = newVersion.split('.').map((e) => int.parse(e)).toList();
      List<int> v2 = currentVersion.split('.').map((e) => int.parse(e)).toList();
      for (int i = 0; i < v1.length && i < v2.length; i++) {
        if (v1[i] > v2[i]) return true;
        if (v1[i] < v2[i]) return false;
      }
      return v1.length > v2.length;
    } catch (_) {
      return false;
    }
  }

  /// Displays the interactive Update Dialog
  static void _showUpdateDialog({
    required BuildContext context,
    required String latestVersion,
    required String apkUrl,
    required String updateMessage,
    required bool forceUpdate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogCtx) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.system_update_alt, color: AppColors.primary, size: 28.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Update Available!', style: AppStyles.heading3.copyWith(fontSize: 18.0)),
                      Text('Version $latestVersion', style: AppStyles.bodySmall.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(updateMessage, style: AppStyles.bodyMedium),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.downloading, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap "Update Now" to download and install the new release in 1-click.',
                          style: TextStyle(fontSize: 11.0, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Later', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                label: const Text('Update Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (apkUrl.isNotEmpty) {
                    final uri = Uri.parse(apkUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
