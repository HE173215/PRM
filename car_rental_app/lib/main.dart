import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const CarRentalApp());
}

class CarRentalApp extends StatelessWidget {
  const CarRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}