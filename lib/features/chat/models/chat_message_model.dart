import 'transaction_model.dart';

enum ChatSender { user, app }

class ChatMessageModel {
  final String id;
  final ChatSender sender;
  String text;
  TransactionModel? transaction;
  DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.transaction,
    required this.timestamp,
  });

  bool get isTransaction => transaction != null;
}
