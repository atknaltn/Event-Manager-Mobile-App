import 'package:event_manager/screens/charts.dart';
import 'package:event_manager/screens/dashboard.dart';
import 'package:event_manager/screens/nodes.dart';
import 'package:event_manager/screens/search.dart';
import 'package:flutter/material.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _currIndex = 0;
  List<Widget> screens = [
    Dashboard(title: 'Dashboard'),
    SearchPage(title: 'Search'),
    ChartsPage(title: 'Charts'),
    NodesPage(title: 'Nodes')
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currIndex,
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Dashboard',
                backgroundColor: Colors.blue),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
                backgroundColor: Colors.blue),
            BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart),
                label: 'Charts',
                backgroundColor: Colors.blue),
            BottomNavigationBarItem(
                icon: Icon(Icons.data_object_sharp),
                label: 'Nodes',
                backgroundColor: Colors.blue)
          ],
          onTap: (index) {
            setState(() {
              _currIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true),
    );
  }
}
