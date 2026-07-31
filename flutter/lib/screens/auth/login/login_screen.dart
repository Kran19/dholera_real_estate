import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../admin/dashboard/admin_dashboard_screen.dart';
import '../../properties/property_list_screen.dart';

/**
 * Login Screen
 * DHOLERA REAL ESTATE — Enhanced with Smooth Entrance & Loading Animations
 */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      UiHelpers.showSnackBar(context, 'Login successful!');
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
      UiHelpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Invalid credentials. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Official Logo Asset Card with subtle shadow
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16.0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.logo,
                          height: 95.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28.0),

                      // Welcome Header
                      Text('Welcome Back', style: AppStyles.heading1),
                      const SizedBox(height: 8.0),
                      Text(
                        'Sign in to access property management & listings',
                        style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28.0),

                      // Input Card Container
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              label: 'Username',
                              hint: 'Enter your username',
                              controller: _usernameController,
                              prefixIcon: Icons.person_outline,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            CustomTextField(
                              label: 'Passcode',
                              hint: 'Enter your passcode',
                              controller: _passwordController,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your passcode';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28.0),
                            CustomButton(
                              text: 'Sign In',
                              isLoading: authProvider.status == AuthStatus.loading,
                              onPressed: _handleLogin,
                              icon: Icons.login,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'DHOLERA REAL ESTATE MANAGEMENT SYSTEM v1.0.2',
                        style: AppStyles.bodySmall.copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
