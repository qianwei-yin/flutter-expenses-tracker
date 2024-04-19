import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:final_project/data/categories.dart';
import 'package:final_project/models/category.dart';
import 'package:final_project/models/transaction_item.dart';

final formatter = DateFormat('y-MM-d');

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _isLoading = true;

  List<String> accountOptions = [];
  DateTime? _pickedDatetime = DateTime.now();

  var _selectedCategory = categories[Categories.restaurant]!;
  double _enteredAmount = 0;
  String _selectedDatetime = formatter.format(DateTime.now());
  String _selectedAccount = '';
  String _enteredDescription = '';

  var _isSending = false;
  bool _hasDatetime = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    final url = Uri.https(
        'info6350-test-default-rtdb.firebaseio.com', 'account-list.json');

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
      for (final item in listData.entries) {
        accountOptions.add(item.value['name']);
      }
      inspect(accountOptions);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _presentDatePicker() async {
    setState(() {
      _hasDatetime = true;
    });
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 3, now.month, now.day);
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    _pickedDatetime = pickedDate;
    setState(() {
      if (pickedDate != null) {
        _selectedDatetime = formatter.format(pickedDate);
      } else {
        _selectedDatetime = '';
      }
    });
  }

  void _saveItem() async {
    // Check date
    if (_selectedDatetime == '') {
      setState(() {
        _hasDatetime = false;
      });
      return;
    }
    // Check other fields
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.https('info6350-test-default-rtdb.firebaseio.com',
          'transaction-items.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'category': _selectedCategory.title,
            'amount': _enteredAmount,
            'datetime': _selectedDatetime,
            'account': _selectedAccount,
            'description': _enteredDescription,
          },
        ),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        TransactionItem(
          id: resData['name'],
          category: _selectedCategory,
          amount: _enteredAmount,
          datetime: _pickedDatetime!,
          account: _selectedAccount,
          description: _enteredDescription,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // DATETIME
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: Text(
                      _selectedDatetime == ''
                          ? 'No date selected'
                          : _selectedDatetime,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _presentDatePicker,
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              // NO DATETIME WARNING
              _hasDatetime
                  ? const SizedBox()
                  : const Text(
                      'Please select a date.',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
              const SizedBox(height: 16),
              // CATEGORY
              DropdownButtonFormField(
                value: _selectedCategory,
                items: [
                  for (final category in categories.entries)
                    DropdownMenuItem(
                      value: category.value,
                      child: Row(
                        children: [
                          category.value.icon,
                          const SizedBox(width: 10),
                          Text(category.value.title),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              //AMOUNT
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Amount'),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                initialValue: '',
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.tryParse(value)! <= 0) {
                    return 'Must be a valid, positive number.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredAmount = double.parse(value!);
                },
              ),
              // ACCOUNT
              DropdownButtonFormField(
                hint: const Text('Select an account'),
                items: [
                  for (final account in accountOptions)
                    DropdownMenuItem(
                      value: account,
                      child: Text(account),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAccount = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Must choose an account.';
                  }
                  return null;
                },
              ),
              // DESCRIPTION
              TextFormField(
                maxLength: 100,
                decoration: const InputDecoration(
                  label: Text('Description (Optional)'),
                ),
                onSaved: (value) {
                  _enteredDescription = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
