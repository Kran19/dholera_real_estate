import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../providers/auth_provider.dart';
import '../auth/login/login_screen.dart';
import '../properties/property_list_screen.dart';
import '../admin/dashboard/admin_dashboard_screen.dart';

/// Splash Screen
/// DHOLERA REAL ESTATE
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initAuth();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      if (authProvider.isSuperAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PropertyListScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Official Logo Asset
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                AppAssets.logo,
                height: 110.0,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16.0),
            Text(
              'REAL ESTATE DEVELOPMENT',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
