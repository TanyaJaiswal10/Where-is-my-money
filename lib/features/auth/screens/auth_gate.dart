import 'package:flutter/material.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../navigation/screens/main_navigation_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await AuthStorageService.getToken();
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  void _onLoggedIn() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onLoggedOut() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_isAuthenticated) {
      return MainNavigationScreen(
        onLoggedOut: _onLoggedOut,
      );
    }

    return LoginScreen(
      onLoginSuccess: _onLoggedIn,
    );
  }
}
