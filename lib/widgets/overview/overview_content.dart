import 'dart:developer';

import 'package:flutter/material.dart';
import "package:final_project/models/transaction_item.dart";
import 'package:final_project/data/categories.dart';
import 'package:final_project/widgets/details/sort_by.dart';

import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();
List<String> incomeCategories = ['Transfer', 'Salary', 'Other Income'];
Map<String, Color> colors = {
  'red': const Color(0xfff87171),
  'green': const Color(0xff84cc16),
  'purple': Colors.deepPurpleAccent,
};

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

      double totalExpenses = filteredTransactionItems.fold(0, (a, b) {
        if (!incomeCategories.contains(b.category.title)) {
          return a + b.amount;
        } else {
          return a;
        }
      });

      double totalIncome = filteredTransactionItems.fold(0, (a, b) {
        if (incomeCategories.contains(b.category.title)) {
          return a + b.amount;
        } else {
          return a;
        }
      });

      Map<String, double> expensesByCategory = {};
      Map<String, double> incomeByCategory = {};
      filteredTransactionItems.forEach((element) {
        if (!incomeCategories.contains(element.category.title)) {
          if (expensesByCategory.containsKey(element.category.title)) {
            expensesByCategory[element.category.title] =
                expensesByCategory[element.category.title]! + element.amount;
          } else {
            expensesByCategory[element.category.title] = element.amount;
          }
        } else {
          if (incomeByCategory.containsKey(element.category.title)) {
            incomeByCategory[element.category.title] =
                incomeByCategory[element.category.title]! + element.amount;
          } else {
            incomeByCategory[element.category.title] = element.amount;
          }
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
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors['purple'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance >= 0 ? '+' : '-'} \$${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    color: balance >= 0 ? colors['green'] : colors['red'],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expenses',
                        style: TextStyle(
                          fontSize: 20,
                          color: colors['red'],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '\$${totalExpenses.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          color: colors['red'],
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                    child: Column(children: [
                      for (var entry in expensesByCategory.entries)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                    ]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 20,
                          color: colors['green'],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '\$${totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          color: colors['green'],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                    child: Column(children: [
                      for (var entry in incomeByCategory.entries)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                    ]),
                  ),
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
