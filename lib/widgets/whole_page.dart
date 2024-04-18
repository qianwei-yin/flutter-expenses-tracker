import 'package:flutter/material.dart';

import 'package:final_project/widgets/page_with_time_range.dart';
import 'package:final_project/widgets/details/details_list.dart';

class WholePage extends StatefulWidget {
  const WholePage({super.key});

  @override
  State<WholePage> createState() => _WholePageState();
}

class _WholePageState extends State<WholePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 2
            ? const Text('Index 2: School')
            : PageWithTimeRange(selectedIndex: _selectedIndex),
        // child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.paid),
            label: 'Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 230, 222, 241),
      ),
    );
  }
}
