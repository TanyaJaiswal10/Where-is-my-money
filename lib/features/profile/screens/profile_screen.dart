import 'package:flutter/material.dart';
import '../../../core/constants/currencies.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLoggedOut;

  const ProfileScreen({
    super.key,
    required this.onLoggedOut,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "User";
  String _email = "user@example.com";
  String _currency = "INR";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final cached = await AuthStorageService.getUserData();
      if (cached != null) {
        setState(() {
          _name = cached['name'] ?? "User";
          _email = cached['email'] ?? "user@example.com";
          _currency = cached['currency'] ?? "INR";
        });
      }

      final profile = await AuthService.fetchProfile();
      setState(() {
        _name = profile['name'] ?? _name;
        _email = profile['email'] ?? _email;
        _currency = profile['currency'] ?? _currency;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCurrencyPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Change Primary Currency",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              Text(
                "This will be your default currency for new transactions. Existing transactions won't be converted.",
                style: TextStyle(
                  fontSize: 13.0,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableCurrencies.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final curr = availableCurrencies[index];
                    final isSelected = _currency == curr.code;

                    return ListTile(
                      leading: Text(curr.flag, style: const TextStyle(fontSize: 22)),
                      title: Text("${curr.code} — ${curr.name}"),
                      subtitle: Text(curr.symbol),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () async {
                        Navigator.pop(context);
                        await _updateCurrency(curr.code);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateCurrency(String newCode) async {
    setState(() {
      _currency = newCode;
    });

    try {
      await ApiClient.put("/auth/me", {"currency": newCode});
      await AuthStorageService.saveUserData({
        "name": _name,
        "email": _email,
        "currency": newCode,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Default currency updated to $newCode for future transactions."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _loadProfile();
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    widget.onLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currItem = getCurrencyByCode(_currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account & Settings"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.5,
            colors: [
              Color(0x38416FE0), // Cobalt blue ambient light source
              Color(0x24C98BFF), // Soft lilac ambient illumination
              Color(0x183159C9), // Royal blue glow
              Color(0xFF080D2B), // Deep Night Blue foundation
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      // Avatar Icon Circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : "U",
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        _name,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        _email,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Settings Card
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
                          borderRadius: AppSpacing.borderRadiusLg,
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                              title: const Text("Full Name"),
                              trailing: Text(
                                _name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                              title: const Text("Email"),
                              trailing: Text(
                                _email,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              onTap: _showCurrencyPicker,
                              leading: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
                              title: const Text("Primary Currency"),
                              subtitle: const Text(
                                "Default for future entries",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySubtle,
                                      borderRadius: AppSpacing.borderRadiusPill,
                                    ),
                                    child: Text(
                                      "${currItem.flag} $_currency",
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Log out button
                      CustomButton(
                        fullWidth: true,
                        variant: ButtonVariant.secondary,
                        text: "Log out",
                        icon: Icons.logout_rounded,
                        onPressed: _handleLogout,
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
