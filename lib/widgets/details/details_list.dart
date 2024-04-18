import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "package:final_project/models/transaction_item.dart";
import 'package:final_project/data/categories.dart';
import 'package:final_project/widgets/details/sort_by.dart';

import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class DetailsList extends StatefulWidget {
  const DetailsList(
      {super.key, required this.timeIndex, required this.filterOption});

  final DateTime timeIndex;
  final String filterOption;

  @override
  State<DetailsList> createState() => _DetailsListState();
}

class _DetailsListState extends State<DetailsList> {
  List<TransactionItem> _transactionItems = [];
  var _isLoading = true;
  String? _error;

  String _sortBy = 'time+';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'info6350-test-default-rtdb.firebaseio.com', 'transaction-items.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<TransactionItem> loadedItems = [];
      for (final item in listData.entries) {
        // print(item);
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          TransactionItem(
            id: item.key,
            category: category,
            amount: item.value['amount'],
            datetime: DateTime.parse(item.value['datetime']),
            account: item.value['account'],
            description: item.value['description'],
          ),
        );
      }
      setState(() {
        _transactionItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

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

  List<TransactionItem> filterTransactionItems(
      List<TransactionItem> transactionItems) {
    final List<TransactionItem> filteredTransactionItems = [];
    for (final item in transactionItems) {
      final bool isSameYear = item.datetime.year == widget.timeIndex.year;
      final bool isSameMonth = item.datetime.month == widget.timeIndex.month;
      final bool isSameDay = item.datetime.day == widget.timeIndex.day;

      if (widget.filterOption == 'Year' && isSameYear) {
        filteredTransactionItems.add(item);
      }
      if (widget.filterOption == 'Month' && isSameMonth && isSameYear) {
        filteredTransactionItems.add(item);
      }
      if (widget.filterOption == 'Day' &&
          isSameDay &&
          isSameMonth &&
          isSameYear) {
        filteredTransactionItems.add(item);
      }
    }
    return filteredTransactionItems;
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
    print(
        "items need to be in the same ${widget.filterOption} as ${widget.timeIndex}");
    print(_sortBy);

    Widget content = const Center(child: Text('No transactions yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    List<TransactionItem> filteredTransactionItems =
        filterTransactionItems(_transactionItems);
    sortTransactionItems(filteredTransactionItems);

    if (filteredTransactionItems.isNotEmpty) {
      content = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'There are 123 transactions.',
                style: TextStyle(
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

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return content;
  }
}
