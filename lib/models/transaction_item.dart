import 'package:final_project/models/category.dart';
import 'package:intl/intl.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.datetime,
    required this.account,
    this.description = '',
  });

  final String id;
  final Category category;
  final double amount;
  final DateTime datetime;
  final String account;
  final String description;
}
