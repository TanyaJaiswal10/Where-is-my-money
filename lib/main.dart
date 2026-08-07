import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WhereIsMyMoneyApp());
}

class WhereIsMyMoneyApp extends StatelessWidget {
  const WhereIsMyMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Where's My Money?",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode for sleek fintech aesthetic
      home: const OnboardingScreen(),
    );
  }
}
