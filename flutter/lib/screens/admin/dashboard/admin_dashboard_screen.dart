import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/inquiry_provider.dart';
import '../../users/user_list_screen.dart';
import '../../properties/property_list_screen.dart';
import '../../properties/add_edit_property_screen.dart';
import '../../inquiry/inquiry_list_screen.dart';
import '../../auth/login/login_screen.dart';

/// Super Admin Dashboard Screen
/// DHOLERA REAL ESTATE
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    Provider.of<UserProvider>(context, listen: false).fetchUsers(refresh: true);
    Provider.of<PropertyProvider>(context, listen: false).fetchProperties(refresh: true);
    Provider.of<InquiryProvider>(context, listen: false).fetchInquiries();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final inquiryProvider = Provider.of<InquiryProvider>(context);

    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Image.asset(AppAssets.logo, height: 26.0),
            ),
            const SizedBox(width: 10.0),
            Text('Admin Dashboard', style: AppStyles.heading3.copyWith(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await UiHelpers.showConfirmDialog(
                context,
                title: 'Logout',
                message: 'Are you sure you want to log out of Super Admin session?',
                confirmText: 'Logout',
              );
              if (confirm && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 11.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Hello, ${currentUser?.username ?? 'Admin'}',
                      style: AppStyles.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Manage properties, customer inquiries & user permissions.',
                      style: AppStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Metrics Cards Row
              Text('System Overview', style: AppStyles.heading3),
              const SizedBox(height: 12.0),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Users',
                      count: '${userProvider.totalUsers}',
                      icon: Icons.people_outline,
                      color: const Color(0xFF3F83F8),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Inquiries',
                      count: '${inquiryProvider.totalInquiries}',
                      icon: Icons.mark_unread_chat_alt_outlined,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Properties',
                      count: '${propertyProvider.totalProperties}',
                      icon: Icons.landscape_outlined,
                      color: const Color(0xFFFF9900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // Action Quick Cards
              Text('Management Actions', style: AppStyles.heading3),
              const SizedBox(height: 16.0),

              _buildActionCard(
                title: 'Customer Inquiries',
                subtitle: 'View customer inquiries, make direct calls & export PDF report',
                icon: Icons.contact_phone_outlined,
                badgeText: '${inquiryProvider.totalInquiries} Inquiries',
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InquiryListScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              _buildActionCard(
                title: 'Property Management',
                subtitle: 'View, search, filter, and modify property listings',
                icon: Icons.business_outlined,
                badgeText: '${propertyProvider.totalProperties} Listed',
                color: AppColors.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PropertyListScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              _buildActionCard(
                title: 'Add New Property',
                subtitle: 'Upload new property details & attach up to 5 photos',
                icon: Icons.add_business_outlined,
                badgeText: 'Create',
                color: AppColors.primaryAccent,
                textColor: AppColors.primaryDark,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddEditPropertyScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              _buildActionCard(
                title: 'User Management',
                subtitle: 'Manage user accounts, passwords & active status',
                icon: Icons.admin_panel_settings_outlined,
                badgeText: '${userProvider.totalUsers} Users',
                color: const Color(0xFF1A1F36),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UserListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          const SizedBox(height: 12.0),
          Text(count, style: AppStyles.heading2),
          const SizedBox(height: 2.0),
          Text(title, style: AppStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Icon(icon, color: textColor, size: 28.0),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppStyles.heading3),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(subtitle, style: AppStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16.0, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
