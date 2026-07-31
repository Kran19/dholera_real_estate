import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/**
 * Animated Loading Indicator Component
 * DHOLERA REAL ESTATE — Pulse Ring + Smooth Spinner Animation
 */
class LoadingWidget extends StatefulWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.35).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad),
    );

    _opacityAnimation = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulsating Halo Ring
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: _opacityAnimation.value),
                      ),
                    ),
                  );
                },
              ),

              // Inner Custom Circular Progress Indicator
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: Color(0xFFE2E8F0),
                ),
              ),

              // Center Icon Accent
              const Icon(
                Icons.apartment,
                size: 20,
                color: AppColors.primaryDark,
              ),
            ],
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 18.0),
            Text(
              widget.message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
