import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/chat_message_model.dart';
import '../models/transaction_model.dart';
import '../services/transaction_api_service.dart';
import '../widgets/app_message_bubble.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/date_separator_widget.dart';
import '../widgets/edit_transaction_sheet.dart';
import '../widgets/transaction_confirmation_card.dart';
import '../widgets/user_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isBackendConnected = true;

  double get _totalTodaySpent {
    double total = 0.0;
    for (var msg in _messages) {
      if (msg.transaction != null && !msg.transaction!.isUndone) {
        if (msg.transaction!.category != "Income") {
          total += msg.transaction!.amount;
        }
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadStoredTransactions();
  }

  bool _isDifferentDay(DateTime date1, DateTime date2) {
    final d1 = date1.toLocal();
    final d2 = date2.toLocal();
    return d1.year != d2.year || d1.month != d2.month || d1.day != d2.day;
  }

  /// Load existing stored transactions from FastAPI backend in chronological order (oldest to newest)
  Future<void> _loadStoredTransactions() async {
    try {
      final transactions = await TransactionApiService.fetchTransactions();
      if (transactions.isNotEmpty) {
        setState(() {
          _messages.clear();
          for (var tx in transactions) {
            _messages.add(
              ChatMessageModel(
                id: "user_${tx.id}",
                sender: ChatSender.user,
                text: tx.rawTitle.isNotEmpty ? "${tx.amount.toStringAsFixed(0)} ${tx.rawTitle}" : "${tx.amount.toStringAsFixed(0)} ${tx.category}",
                timestamp: tx.timestamp.toLocal(),
              ),
            );
            _messages.add(
              ChatMessageModel(
                id: "app_${tx.id}",
                sender: ChatSender.app,
                text: "Added ${tx.formattedAmount} to ${tx.category}",
                transaction: tx,
                timestamp: tx.timestamp.toLocal(),
              ),
            );
          }
          _isBackendConnected = true;
        });
        _scrollToBottom();
      }
    } catch (_) {
      setState(() {
        _isBackendConnected = false;
      });
    }
  }

  Map<String, dynamic>? _pendingContext;

  Future<void> _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final userMsg = ChatMessageModel(
      id: now.millisecondsSinceEpoch.toString(),
      sender: ChatSender.user,
      text: cleanText,
      timestamp: now,
    );

    setState(() {
      _messages.add(userMsg);
    });
    _scrollToBottom();

    try {
      final parseResult = await TransactionApiService.parseNaturalLanguage(
        cleanText,
        pendingContext: _pendingContext,
      );
      final String status = parseResult['status'] ?? 'needs_clarification';

      if (status == 'undo_success') {
        _pendingContext = null;
        _handleConversationalUndo(parseResult['message'] ?? 'Transaction removed.');
      } else if (status == 'needs_clarification') {
        _pendingContext = parseResult['pending_context'];
        final clarificationMsg = ChatMessageModel(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          sender: ChatSender.app,
          text: parseResult['message'] ?? 'Could you clarify the details?',
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(clarificationMsg);
          _isBackendConnected = true;
        });
      } else if (status == 'unusual_warning') {
        _renderUnusualWarningMessage(cleanText, parseResult);
      } else if (status == 'success') {
        _pendingContext = null;
        final List<TransactionModel> txList = (parseResult['transactions'] as List<TransactionModel>?) ?? [];
        if (txList.isEmpty && parseResult['transaction'] != null) {
          txList.add(parseResult['transaction'] as TransactionModel);
        }

        if (txList.isNotEmpty) {
          userMsg.timestamp = txList.first.timestamp.toLocal();
        }

        final List<ChatMessageModel> newAppMsgs = [];
        final int baseTime = DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < txList.length; i++) {
          final tx = txList[i];
          newAppMsgs.add(
            ChatMessageModel(
              id: "${baseTime}_$i",
              sender: ChatSender.app,
              text: "Added ${tx.formattedAmount} to ${tx.category}",
              transaction: tx,
              timestamp: tx.timestamp.toLocal(),
            ),
          );
        }

        setState(() {
          _messages.addAll(newAppMsgs);
          _isBackendConnected = true;
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _isBackendConnected = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      _showErrorSnackBar("Unexpected error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _renderUnusualWarningMessage(String rawPrompt, Map<String, dynamic> warningData) {
    final warningMsg = ChatMessageModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      sender: ChatSender.app,
      text: warningData['message'] ?? 'Unusually high amount.',
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(warningMsg);
      _isBackendConnected = true;
    });

    _showUnusualWarningDialog(rawPrompt, warningData);
  }

  void _showUnusualWarningDialog(String rawPrompt, Map<String, dynamic> warningData) {
    final category = warningData['category'] as String;
    final origAmount = warningData['original_amount'] as double;
    final suggAmount = warningData['suggested_amount'] as double;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFA10164A), // Translucent Deep Navy Glass
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0x3D6D9AF5), width: 1.2),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.amberAccent, size: 22),
              SizedBox(width: 8),
              Text(
                "Unusual Amount",
                style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white, // Pure White #FFFFFF
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "₹${origAmount.toStringAsFixed(0)} seems unusually high for $category.",
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white, // Pure White #FFFFFF
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Did you mean ₹${suggAmount.toStringAsFixed(0)}?",
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD9DEFF), // Cool White-Lavender #D9DEFF
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          actions: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Suggested Amount Button: e.g. "Use ₹450"
                InkWell(
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _confirmUnusualAmount(rawPrompt, suggAmount, true);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x6019235A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x50B4C8FF), width: 1.0),
                    ),
                    child: Text(
                      "Use ₹${suggAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // Pure White #FFFFFF
                      ),
                    ),
                  ),
                ),

                // Original Amount Override Button: e.g. "Keep ₹45,000"
                InkWell(
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _confirmUnusualAmount(rawPrompt, origAmount, true);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x60B879FF),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      "Keep ₹${origAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white, // Pure White #FFFFFF
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmUnusualAmount(String text, double chosenAmount, bool override) async {
    try {
      final parseResult = await TransactionApiService.parseNaturalLanguage(
        text,
        confirmUnusual: override,
        overrideAmount: chosenAmount,
      );

      if (parseResult['status'] == 'success') {
        final tx = parseResult['transaction'];
        final appMsg = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: ChatSender.app,
          text: "Added ${tx.formattedAmount} to ${tx.category}",
          transaction: tx,
          timestamp: tx.timestamp.toLocal(),
        );

        setState(() {
          _messages.add(appMsg);
        });
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackBar("Failed to save transaction: $e");
    }
  }

  void _handleConversationalUndo(String feedbackMsg) {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].transaction != null && !_messages[i].transaction!.isUndone) {
        setState(() {
          _messages[i].transaction!.isUndone = true;
        });
        break;
      }
    }

    final feedbackBubble = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: ChatSender.app,
      text: feedbackMsg,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(feedbackBubble);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedbackMsg),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleUndo(ChatMessageModel msg) async {
    if (msg.transaction == null || msg.transaction!.isUndone) return;

    final txId = int.tryParse(msg.transaction!.id);
    if (txId != null) {
      await TransactionApiService.deleteTransaction(txId);
    }

    setState(() {
      msg.transaction!.isUndone = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.undo_rounded, color: Color(0xFFC98BFF), size: 18),
              SizedBox(width: 8),
              Text(
                "Transaction removed.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF10164A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0x50B4C8FF), width: 1.0),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleEdit(ChatMessageModel msg) {
    if (msg.transaction == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (sheetContext) {
        return EditTransactionSheet(
          transaction: msg.transaction!,
          onSave: ({
            required amount,
            required description,
            required category,
            required date,
          }) async {
            final txId = int.tryParse(msg.transaction!.id);
            if (txId != null) {
              try {
                final updated = await TransactionApiService.updateTransaction(txId, {
                  "amount": amount,
                  "description": description,
                  "category": category,
                  "transaction_date": date.toIso8601String(),
                });

                setState(() {
                  msg.transaction = updated;
                  msg.transaction!.isUndone = false;
                  msg.text = "Added ${updated.formattedAmount} to ${updated.category}";
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "✓ Updated to ${updated.formattedAmount} in ${updated.category}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                        ),
                      ),
                      backgroundColor: const Color(0xFF10164A),
                      behavior: SnackBarBehavior.floating,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(color: Color(0x50B4C8FF), width: 1.0),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                _showErrorSnackBar("Failed to update transaction: $e");
              }
            }
          },
        );
      },
    );
  }

  void _handleChangeCategory(ChatMessageModel msg) {
    if (msg.transaction == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Correct Category",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "One-tap category correction for ${msg.transaction!.formattedAmount}",
                  style: TextStyle(
                    fontSize: 13.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildCategoryOption("Food", Icons.fastfood_outlined, msg, sheetContext),
                    _buildCategoryOption("Transport", Icons.directions_car_outlined, msg, sheetContext),
                    _buildCategoryOption("Housing", Icons.home_outlined, msg, sheetContext),
                    _buildCategoryOption("Bills", Icons.receipt_long_outlined, msg, sheetContext),
                    _buildCategoryOption("Shopping", Icons.shopping_bag_outlined, msg, sheetContext),
                    _buildCategoryOption("Entertainment", Icons.movie_outlined, msg, sheetContext),
                    _buildCategoryOption("Health", Icons.medical_services_outlined, msg, sheetContext),
                    _buildCategoryOption("Other", Icons.more_horiz_rounded, msg, sheetContext),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryOption(
    String categoryName,
    IconData icon,
    ChatMessageModel msg,
    BuildContext sheetContext,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(categoryName),
      onPressed: () async {
        Navigator.pop(sheetContext);

        final txId = int.tryParse(msg.transaction!.id);
        if (txId != null) {
          try {
            final updated = await TransactionApiService.updateTransaction(
              txId,
              {"category": categoryName},
            );

            setState(() {
              msg.transaction = updated;
              msg.text = "Added ${updated.formattedAmount} to ${updated.category}";
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "✓ Changed category to ${updated.category}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                    ),
                  ),
                  backgroundColor: const Color(0xFF10164A),
                  behavior: SnackBarBehavior.floating,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    side: BorderSide(color: Color(0x50B4C8FF), width: 1.0),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            _showErrorSnackBar("Failed to update: $e");
          }
        }
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13.0, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.roseAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
              decoration: BoxDecoration(
                color: _isBackendConnected ? AppColors.primary : AppColors.amberAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isBackendConnected ? const Color(0x66E21D3F) : const Color(0x66F59E0B),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text("Where's My Money?"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: "Refresh Transactions",
            onPressed: _loadStoredTransactions,
          ),
        ],
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
              // Top Spending Ribbon
              if (_messages.isNotEmpty)
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
                              "TOTAL SPENDING",
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹${_totalTodaySpent.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
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

              // Chat Messages / Empty State
              Expanded(
                child: _messages.isEmpty
                    ? ChatEmptyState(onSelectPrompt: _sendMessage)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final showDateHeader = index == 0 || _isDifferentDay(_messages[index - 1].timestamp, msg.timestamp);

                          Widget itemWidget;
                          if (msg.sender == ChatSender.user) {
                            itemWidget = UserMessageBubble(
                              message: msg.text,
                              timestamp: msg.timestamp.toLocal(),
                            );
                          } else if (msg.transaction != null) {
                            itemWidget = TransactionConfirmationCard(
                              transaction: msg.transaction!,
                              onUndo: () => _handleUndo(msg),
                              onEdit: () => _handleEdit(msg),
                              onChangeCategory: () => _handleChangeCategory(msg),
                            );
                          } else {
                            itemWidget = AppMessageBubble(
                              message: msg.text,
                              timestamp: msg.timestamp.toLocal(),
                            );
                          }

                          if (showDateHeader) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DateSeparatorWidget(date: msg.timestamp),
                                itemWidget,
                              ],
                            );
                          }
                          return itemWidget;
                        },
                      ),
              ),

              // Bottom Input Pill Bar
              ChatInputBar(onSend: _sendMessage),
            ],
          ),
        ),
      ),
    ),
  );
}
}
