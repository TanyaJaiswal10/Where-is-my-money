import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = "Please enter a valid email address.";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your password.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.login(email: email, password: password);
      widget.onLoginSuccess();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred during login. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xl,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Brand Logo & Title
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        "Where's My Money?",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Log in to manage your conversational expenses and financial insights.",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.roseAccent.withValues(alpha: 0.12),
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(color: AppColors.roseAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.roseAccent),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 13.0, color: AppColors.roseAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Email Field
                  Text(
                    "EMAIL ADDRESS",
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "you@example.com",
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password Field
                  Text(
                    "PASSWORD",
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Forgot Password Placeholder
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password reset instructions sent if email exists."),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Log In Primary Button
                  CustomButton(
                    fullWidth: true,
                    isLoading: _isLoading,
                    text: "Log In",
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Switch to Signup Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(
                                onSignupSuccess: widget.onLoginSuccess,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
