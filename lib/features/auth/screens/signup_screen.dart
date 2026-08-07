import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/currencies.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignupSuccess;

  const SignupScreen({
    super.key,
    required this.onSignupSuccess,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedCurrency = "INR";
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _errorMessage = "Please enter your full name.");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = "Please enter a valid email address.");
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters.");
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.register(
        name: name,
        email: email,
        password: password,
        currency: _selectedCurrency,
      );
      if (!mounted) return;
      Navigator.pop(context); // Close signup screen back to AuthGate
      widget.onSignupSuccess();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Registration failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Join Where's My Money?",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Create your secure user account to start tracking expenses conversationally.",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

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

                  // Full Name
                  Text(
                    "FULL NAME",
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Alice Johnson",
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Email Address
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
                  const SizedBox(height: AppSpacing.md),

                  // Primary Account Currency Selection
                  Text(
                    "PRIMARY ACCOUNT CURRENCY",
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: availableCurrencies.take(6).map((c) {
                      final isSelected = _selectedCurrency == c.code;
                      return ChoiceChip(
                        label: Text("${c.flag} ${c.code}"),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCurrency = c.code);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

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
                      hintText: "At least 6 characters",
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
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
                  const SizedBox(height: AppSpacing.md),

                  // Confirm Password Field
                  Text(
                    "CONFIRM PASSWORD",
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Re-enter password",
                      prefixIcon: const Icon(Icons.lock_clock_outlined, size: 20),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Create Account Button
                  CustomButton(
                    fullWidth: true,
                    isLoading: _isLoading,
                    text: "Create Account",
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
