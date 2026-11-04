import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService authService = AuthService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
    checkLogin();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> checkLogin() async {
    // Cho phép hiển thị splash tối thiểu 1.5s để tạo trải nghiệm mượt mà
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final isLoggedIn = await authService.isLoggedIn();
      if (!mounted) return;

      if (isLoggedIn) {
        try {
          await authService.getProfile();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } catch (_) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow Orbs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(40),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withAlpha(30),
              ),
            ),
          ),

          // Central Branding Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Icon Container
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(120),
                            blurRadius: 36,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // App Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'LUXURY ',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'RENTAL',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Slogan
                    const Text(
                      'Khởi đầu mọi hành trình đẳng cấp',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Loading indicator
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Version note bottom
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'Phiên bản 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}