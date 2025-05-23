import 'package:flutter/material.dart';

class DailyTrackerPage extends StatelessWidget {
  const DailyTrackerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            child: ListTile(
              title: const Text('May 22'),
              trailing: const Text('4/5 done'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('May 21'),
              trailing: const Text('3/5 done'),
            ),
          ),
        ],
      ),
    );
  }
}