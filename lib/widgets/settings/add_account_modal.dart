import 'package:flutter/material.dart';

import 'package:final_project/models/account_item.dart';

class AddAccountModal extends StatefulWidget {
  const AddAccountModal({
    super.key,
    required this.accountOptions,
    required this.addAccountItem,
  });

  final List<AccountItem> accountOptions;
  final void Function(String item) addAccountItem;

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  String? _error;
  final TextEditingController _textController = TextEditingController();

  void _validateInputAndSubmit() {
    setState(() {
      _error = null;
    });

    String? inputValue = _textController.text;

    if (inputValue.isEmpty) {
      setState(() {
        _error = 'Please enter a name.';
      });
      return;
    }
    for (final element in widget.accountOptions) {
      if (element.name == inputValue) {
        setState(() {
          _error = 'This name already exists.';
        });
        return;
      }
    }

    widget.addAccountItem(inputValue);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Enter the name of the account:'),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Type a unique name...',
              border: OutlineInputBorder(),
            ),
          ),
          _error != null
              ? Text(
                  _error!,
                  style: const TextStyle(color: Color(0xfff87171)),
                )
              : const SizedBox(height: 5),
          ElevatedButton(
            onPressed: _validateInputAndSubmit,
            child: const Text('Submit'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
