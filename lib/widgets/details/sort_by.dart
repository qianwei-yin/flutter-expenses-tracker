import 'package:flutter/material.dart';

typedef SortByCallback = void Function(String val);

Map<String, String> sortByOptions = {
  'time+': 'Time (earliest first)',
  'time-': 'Time (latest first)',
  'categorya2z': 'Category (A-Z)',
  'categoryz2a': 'Category (Z-A)',
  'amount+': 'Amount (low to high)',
  'amount-': 'Amount (high to low)',
};

class SortBy extends StatefulWidget {
  final SortByCallback callback;

  const SortBy({super.key, required this.callback});

  @override
  State<SortBy> createState() => _SortByState();
}

class _SortByState extends State<SortBy> {
  String _sortBy = 'time-';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),
      isDense: true,
      value: _sortBy,
      onChanged: (String? newValue) {
        setState(() {
          _sortBy = newValue!;
        });
        widget.callback(newValue!);
      },
      items: sortByOptions.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
    );
    // return Padding(
    //   padding: const EdgeInsets.all(16.0),
    //   child: ElevatedButton(
    //     child: const Text('test'),
    //     onPressed: () {
    //       callback('time+');
    //     },
    //   ),
    // );
  }
}
