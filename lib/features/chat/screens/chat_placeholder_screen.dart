import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../widgets/suggested_prompt_chip.dart';

class ChatPlaceholderScreen extends StatefulWidget {
  const ChatPlaceholderScreen({super.key});

  @override
  State<ChatPlaceholderScreen> createState() => _ChatPlaceholderScreenState();
}

class _ChatPlaceholderScreenState extends State<ChatPlaceholderScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _sampleMessages = [
    {
      'sender': 'user',
      'text': '250 snacks',
      'time': '10:42 AM',
    },
    {
      'sender': 'app',
      'text': 'Added ₹250 to Food 🍔',
      'category': 'Food & Dining',
      'time': '10:42 AM',
    },
    {
      'sender': 'user',
      'text': '1200 uber ride to office',
      'time': '12:15 PM',
    },
    {
      'sender': 'app',
      'text': 'Added ₹1,200 to Transport 🚕',
      'category': 'Transportation',
      'time': '12:15 PM',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPromptSelected(String text) {
    setState(() {
      _controller.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text("Where's My Money?"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Status Ribbon
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S SPENDING",
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "₹1,450",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: AppSpacing.borderRadiusPill,
                              ),
                              child: const Text(
                                "2 entries",
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Conversational Feed
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _sampleMessages.length,
                itemBuilder: (context, index) {
                  final msg = _sampleMessages[index];
                  final isUser = msg['sender'] == 'user';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                              : AppColors.primarySubtle,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(AppSpacing.radiusLg),
                            topRight: const Radius.circular(AppSpacing.radiusLg),
                            bottomLeft: Radius.circular(isUser ? AppSpacing.radiusLg : AppSpacing.radiusSm),
                            bottomRight: Radius.circular(isUser ? AppSpacing.radiusSm : AppSpacing.radiusLg),
                          ),
                          border: Border.all(
                            color: isUser
                                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                                : AppColors.primary.withValues(alpha: 0.25),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text']!,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: isUser ? FontWeight.w500 : FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time']!,
                              style: TextStyle(
                                fontSize: 11.0,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Quick Try Suggestions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  SuggestedPromptChip(
                    prompt: "250 snacks",
                    label: "250 snacks",
                    icon: Icons.fastfood_outlined,
                    onTap: () => _onPromptSelected("250 snacks"),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SuggestedPromptChip(
                    prompt: "1200 uber ride",
                    label: "1200 uber ride",
                    icon: Icons.directions_car_outlined,
                    onTap: () => _onPromptSelected("1200 uber ride"),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SuggestedPromptChip(
                    prompt: "15000 salary credited",
                    label: "15000 salary",
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => _onPromptSelected("15000 salary credited"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Conversational Input Pill Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: AppSpacing.borderRadiusPill,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type e.g. '250 snacks'...",
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: TextStyle(
                          fontSize: 15.0,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            setState(() {
                              _sampleMessages.add({
                                'sender': 'user',
                                'text': _controller.text,
                                'time': 'Just now',
                              });
                              _controller.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
