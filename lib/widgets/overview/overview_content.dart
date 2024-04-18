import 'dart:developer';

import 'package:flutter/material.dart';
import "package:final_project/models/transaction_item.dart";
import 'package:final_project/data/categories.dart';
import 'package:final_project/widgets/details/sort_by.dart';

import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();
List<String> incomeCategories = ['Transfer', 'Salary', 'Other Income'];

class OverviewContent extends StatefulWidget {
  const OverviewContent(
      {super.key,
      required this.filteredTransactionItems,
      required this.error,
      required this.isLoading});

  final List<TransactionItem> filteredTransactionItems;
  final String? error;
  final bool isLoading;

  @override
  State<OverviewContent> createState() => _OverviewContentState();
}

class _OverviewContentState extends State<OverviewContent> {
  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No transactions yet.'));

    if (widget.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null) {
      content = Center(child: Text(widget.error!));
    }

    List<TransactionItem> filteredTransactionItems =
        widget.filteredTransactionItems;
    inspect(filteredTransactionItems);

    if (filteredTransactionItems.isNotEmpty) {
      double balance = filteredTransactionItems.fold(0, (a, b) {
        if (incomeCategories.contains(b.category.title)) {
          return a + b.amount;
        } else {
          return a - b.amount;
        }
      });

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance >= 0 ? '+' : '-'} \$${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    color: balance >= 0
                        ? const Color(0xff84cc16)
                        : const Color(0xfff87171),
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${balance >= 0 ? '+' : '-'} \$${balance.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      color: balance >= 0
                          ? const Color(0xff84cc16)
                          : const Color(0xfff87171),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }
}
