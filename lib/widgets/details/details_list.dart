import 'dart:developer';

import 'package:flutter/material.dart';
import "package:final_project/models/transaction_item.dart";
import 'package:final_project/data/categories.dart';
import 'package:final_project/widgets/details/sort_by.dart';

import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class DetailsList extends StatefulWidget {
  const DetailsList(
      {super.key,
      required this.filteredTransactionItems,
      required this.error,
      required this.isLoading});

  final List<TransactionItem> filteredTransactionItems;
  final String? error;
  final bool isLoading;

  @override
  State<DetailsList> createState() => _DetailsListState();
}

class _DetailsListState extends State<DetailsList> {
  String _sortBy = 'time+';

  void _addItem() async {
    // final newItem = await Navigator.of(context).push<TransactionItem>(
    //   MaterialPageRoute(
    //     builder: (ctx) => const NewItem(),
    //   ),
    // );

    // if (newItem == null) {
    //   return;
    // }

    // setState(() {
    //   _transactionItems.add(newItem);
    // });
  }

  void _removeItem(TransactionItem item) async {
    print('delete');
    // final index = _transactionItems.indexOf(item);
    // setState(() {
    //   _transactionItems.remove(item);
    // });

    // final url = Uri.https('info6350-test-default-rtdb.firebaseio.com',
    //     'shopping-list/${item.id}.json');

    // final response = await http.delete(url);

    // if (response.statusCode >= 400) {
    //   // Optional: Show error message
    //   setState(() {
    //     _transactionItems.insert(index, item);
    //   });
    // }
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
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        _removeItem(item);
                      }
                      if (direction == DismissDirection.startToEnd) {
                        print('edit');
                      }
                    },
                    key: ValueKey(item.id),
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
                  );
                }),
          ),
        ],
      );
    }

    return content;
  }
}
