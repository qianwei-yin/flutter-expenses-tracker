import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:http/http.dart" as http;

import 'package:final_project/data/categories.dart';
import "package:final_project/models/transaction_item.dart";

import 'package:final_project/widgets/details/details_list.dart';
import "package:final_project/widgets/overview/overview_content.dart";

List<String> filterOptions = ['Year', 'Month', 'Day'];
Map<String, DateFormat> formatter = {
  'Year': DateFormat.y(),
  'Month': DateFormat.yMMMM(),
  'Day': DateFormat.yMMMMd('en_US'),
};
Map<String, int> timeDiff = {
  'Year': 365,
  'Month': 30,
  'Day': 1,
};

class PageWithTimeRange extends StatefulWidget {
  const PageWithTimeRange({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<PageWithTimeRange> createState() => _PageWithTimeRangeState();
}

class _PageWithTimeRangeState extends State<PageWithTimeRange> {
  List<TransactionItem> loadedItems = [];
  DateTime timeIndex = DateTime.now();
  String filterOption = 'Month';
  String currentPeriod = formatter['Month']!.format(DateTime.now());

  String? _error;
  bool _isLoading = true;
  List<TransactionItem> _filteredTransactionItems = [];

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

      // no data in database
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      // final List<TransactionItem> loadedItems = [];
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

      updateStateOfFilteredTransactionItems();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  updateStateOfFilteredTransactionItems() {
    setState(() {
      _filteredTransactionItems = filterTransactionItems(loadedItems);
    });
  }

  List<TransactionItem> filterTransactionItems(
      List<TransactionItem> transactionItems) {
    final List<TransactionItem> filteredTransactionItems = [];
    for (final item in transactionItems) {
      final bool isSameYear = item.datetime.year == timeIndex.year;
      final bool isSameMonth = item.datetime.month == timeIndex.month;
      final bool isSameDay = item.datetime.day == timeIndex.day;

      if (filterOption == 'Year' && isSameYear) {
        filteredTransactionItems.add(item);
      }
      if (filterOption == 'Month' && isSameMonth && isSameYear) {
        filteredTransactionItems.add(item);
      }
      if (filterOption == 'Day' && isSameDay && isSameMonth && isSameYear) {
        filteredTransactionItems.add(item);
      }
    }
    return filteredTransactionItems;
  }

  void setFilterOption(String? value) {
    setState(() {
      timeIndex = DateTime.now();
      filterOption = value!;
      currentPeriod = formatter[value]!.format(timeIndex);
      _filteredTransactionItems = filterTransactionItems(loadedItems);
    });
  }

  void backOnePeriod() {
    setState(() {
      timeIndex = timeIndex.subtract(Duration(days: timeDiff[filterOption]!));
      currentPeriod = formatter[filterOption]!.format(timeIndex);
      _filteredTransactionItems = filterTransactionItems(loadedItems);
    });
  }

  void forwardOnePeriod() {
    setState(() {
      timeIndex = timeIndex.add(Duration(days: timeDiff[filterOption]!));
      currentPeriod = formatter[filterOption]!.format(timeIndex);
      _filteredTransactionItems = filterTransactionItems(loadedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: filterOptions.map((option) {
                return Row(children: [
                  Radio(
                    value: option,
                    groupValue: filterOption,
                    onChanged: setFilterOption,
                  ),
                  Text(option),
                ]);
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: backOnePeriod,
                  child: const Icon(Icons.arrow_back),
                ),
                Text(
                  currentPeriod,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                TextButton(
                  onPressed: forwardOnePeriod,
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: widget.selectedIndex == 0
              ? OverviewContent(
                  filteredTransactionItems: _filteredTransactionItems,
                  error: _error,
                  isLoading: _isLoading)
              : DetailsList(
                  filteredTransactionItems: _filteredTransactionItems,
                  error: _error,
                  isLoading: _isLoading,
                  callback: (item, action) {
                    if (action == 'add') {
                      loadedItems.add(item);
                    } else {
                      loadedItems.remove(item);
                    }
                    updateStateOfFilteredTransactionItems();
                  },
                ),
        ),
      ],
    );
  }
}
