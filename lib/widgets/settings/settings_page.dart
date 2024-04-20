import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:final_project/models/account_item.dart';
import "package:final_project/widgets/settings/add_account_modal.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _error;
  bool _isLoading = true;
  List<AccountItem> accountOptions = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    accountOptions = [];

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
        accountOptions.add(
          AccountItem(
            id: item.key,
            name: item.value['name'],
          ),
        );
      }
      print(accountOptions);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _removeItem(AccountItem item) async {
    final url = Uri.https('info6350-test-default-rtdb.firebaseio.com',
        'account-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        accountOptions.add(item);
      });
    }
  }

  void _addAccountItem(String item) async {
    final url = Uri.https(
        'info6350-test-default-rtdb.firebaseio.com', 'account-list.json');

    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {'name': item},
      ),
    );

    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Expanded(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Accounts',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: accountOptions.length,
                    itemBuilder: (ctx, index) {
                      final item = accountOptions[index];

                      return Dismissible(
                          key: ValueKey(item.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removeItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account deleted'),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(item.name),
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
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return AddAccountModal(
                        accountOptions: accountOptions,
                        addAccountItem: _addAccountItem,
                      );
                    },
                  );
                },
                child: const Text('Add an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
