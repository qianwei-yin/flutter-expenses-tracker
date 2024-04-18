import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:final_project/widgets/details/details_list.dart';

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
  DateTime timeIndex = DateTime.now();
  String filterOption = 'Month';
  String currentPeriod = formatter['Month']!.format(DateTime.now());

  void setFilterOption(String? value) {
    setState(() {
      timeIndex = DateTime.now();
      filterOption = value!;
      currentPeriod = formatter[value]!.format(timeIndex);
    });
  }

  void backOnePeriod() {
    setState(() {
      timeIndex = timeIndex.subtract(Duration(days: timeDiff[filterOption]!));
      currentPeriod = formatter[filterOption]!.format(timeIndex);
    });
  }

  void forwardOnePeriod() {
    setState(() {
      timeIndex = timeIndex.add(Duration(days: timeDiff[filterOption]!));
      currentPeriod = formatter[filterOption]!.format(timeIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(timeIndex);
    print(widget.selectedIndex);
    // print('here');

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
              ? const Text('Index 0: Overview')
              : const DetailsList(),
        ),
      ],
    );
  }
}
