import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/network/update_checker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../providers/auth_provider.dart';
import '../auth/login/login_screen.dart';

/**
 * User Profile & Logout Screen
 * DHOLERA REAL ESTATE
 */
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('My Profile', style: AppStyles.heading3.copyWith(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Avatar & Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: user?.isSuperAdmin == true ? AppColors.primary : AppColors.secondary,
                    child: Icon(
                      user?.isSuperAdmin == true ? Icons.admin_panel_settings : Icons.person,
                      size: 40.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(user?.username ?? 'User', style: AppStyles.heading2),
                  const SizedBox(height: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: user?.isSuperAdmin == true ? AppColors.primaryAccent : const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? 'USER',
                      style: TextStyle(
                        color: user?.isSuperAdmin == true ? AppColors.primaryDark : const Color(0xFF3730A3),
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Information Details Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildProfileRow('Account ID', '#${user?.id ?? 0}', Icons.numbers),
                  const Divider(height: 24.0, color: AppColors.border),
                  _buildProfileRow('Username', user?.username ?? '-', Icons.person_outline),
                  const Divider(height: 24.0, color: AppColors.border),
                  _buildProfileRow('Installed App Version', 'v${ApiConfig.currentAppVersion}', Icons.system_update),
                  const Divider(height: 24.0, color: AppColors.border),
                  _buildProfileRow('Account Status', user?.status.toUpperCase() ?? 'ACTIVE', Icons.verified_user_outlined),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Check for Updates Action Card
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                label: const Text('Check for Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                onPressed: () {
                  UpdateChecker.checkForUpdates(context, showNoUpdateToast: true);
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52.0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () async {
                  final confirm = await UiHelpers.showConfirmDialog(
                    context,
                    title: 'Sign Out',
                    message: 'Are you sure you want to log out of Dholera Real Estate?',
                    confirmText: 'Sign Out',
                  );
                  if (confirm && context.mounted) {
                    await authProvider.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32.0),

            // Branding Image
            Image.asset(AppAssets.logo, height: 40.0, fit: BoxFit.contain),
            const SizedBox(height: 8.0),
            Text('DHOLERA REAL ESTATE v${ApiConfig.currentAppVersion}', style: AppStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20.0),
        const SizedBox(width: 12.0),
        Text(label, style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
