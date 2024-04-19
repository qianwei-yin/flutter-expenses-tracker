import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import "package:final_project/models/transaction_item.dart";
import 'package:final_project/data/categories.dart';
import 'package:final_project/widgets/details/sort_by.dart';
import "package:final_project/widgets/new_item.dart";

import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();
typedef LoadedItemsCallback = void Function(TransactionItem val, String action);

class DetailsList extends StatefulWidget {
  const DetailsList({
    super.key,
    required this.filteredTransactionItems,
    required this.error,
    required this.isLoading,
    required this.callback,
  });

  final List<TransactionItem> filteredTransactionItems;
  final String? error;
  final bool isLoading;

  final LoadedItemsCallback callback;

  @override
  State<DetailsList> createState() => _DetailsListState();
}

class _DetailsListState extends State<DetailsList> {
  String _sortBy = 'time-';

  void _addItem() async {
    final newItem = await Navigator.of(context).push<TransactionItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    widget.callback(newItem, 'add');
  }

  void _removeItem(TransactionItem item) async {
    widget.callback(item, 'remove');

    final url = Uri.https('info6350-test-default-rtdb.firebaseio.com',
        'transaction-items/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      widget.callback(item, 'add');
    }
  }

  void sortTransactionItems(List<TransactionItem> transactionItems) {
    transactionItems.sort((a, b) {
      if (_sortBy == 'time+') {
        return a.datetime.compareTo(b.datetime);
      }
      if (_sortBy == 'time-') {
        return b.datetime.compareTo(a.datetime);
      }
      if (_sortBy == 'categorya2z') {
        return a.category.title.compareTo(b.category.title);
      }
      if (_sortBy == 'categoryz2a') {
        return b.category.title.compareTo(a.category.title);
      }
      if (_sortBy == 'amount+') {
        return a.amount.compareTo(b.amount);
      }
      if (_sortBy == 'amount-') {
        return b.amount.compareTo(a.amount);
      }
      return 0;
    });
  }

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
    sortTransactionItems(filteredTransactionItems);

    if (filteredTransactionItems.isNotEmpty) {
      content = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'There are ${filteredTransactionItems.length} transactions.',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SortBy(callback: (val) {
                setState(() {
                  _sortBy = val;
                });
              }),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: filteredTransactionItems.length,
                itemBuilder: (ctx, index) {
                  final item = filteredTransactionItems[index];
                  inspect(item);

                  return Dismissible(
                      key: ValueKey(item.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removeItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction deleted'),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(item.category.title),
                        subtitle: Text(
                          formatter.format(item.datetime),
                        ),
                        leading: categories.entries
                            .firstWhere((catItem) =>
                                catItem.value.title == item.category.title)
                            .value
                            .icon,
                        trailing: Text(
                          '\$${item.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'DELETE',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      });
                }),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: content,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: SizedBox(
            width: double.infinity,
            child: FloatingActionButton(
              onPressed: _addItem,
              backgroundColor: Colors.purple[50],
              foregroundColor: Colors.deepPurple,
              elevation: 2,
              child: const Icon(Icons.add),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
