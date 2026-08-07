import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasContent = _textController.text.trim().isNotEmpty;
    if (hasContent != _hasText) {
      setState(() {
        _hasText = hasContent;
      });
    }
  }

  void _handleSubmitted() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? AppSpacing.sm
            : AppSpacing.md,
      ),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: AppSpacing.borderRadiusPill,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: const Color(0xBF0B1035), // Dark Translucent Navy Glass
                borderRadius: AppSpacing.borderRadiusPill,
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.lilacAccent
                      : AppColors.darkBorder,
                  width: 1.2,
                ),
                boxShadow: _focusNode.hasFocus
                    ? const [
                        BoxShadow(
                          color: Color(0x50B879FF),
                          blurRadius: 22.0,
                          spreadRadius: 1.0,
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 18.0,
                          offset: Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmitted(),
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextPrimary, // Pure White #FFFFFF
                      ),
                      decoration: const InputDecoration(
                        hintText: "Type e.g. '250 snacks'...",
                        hintStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.placeholderText, // Crisp #AEB8E5
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: _hasText ? AppColors.primaryButtonGradient : null,
                      color: _hasText ? null : const Color(0xFF151B58),
                      shape: BoxShape.circle,
                      boxShadow: _hasText
                          ? const [
                              BoxShadow(
                                color: Color(0x60B879FF),
                                blurRadius: 14.0,
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _hasText ? _handleSubmitted : null,
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 20,
                            color: _hasText
                                ? Colors.white
                                : AppColors.darkTextMuted,
                          ),
                        ),
                      ),
                    ),
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
