import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Weekly Completed Tasks'),
                subtitle: const Text('15/20 tasks'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('Monthly Streak'),
                subtitle: const Text('5 days'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Text('Placeholder for Chart'),
            ),
          ],
        ),
      ),
    );
  }
}