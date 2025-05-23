import 'package:flutter/material.dart';

class SectorOverviewPage extends StatelessWidget {
  const SectorOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sectors'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            child: ListTile(
              title: const Text('Diet'),
              onTap: () => print('Diet sector tapped'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Gym'),
              onTap: () => print('Gym sector tapped'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Finance'),
              onTap: () => print('Finance sector tapped'),
            ),
          ),
        ],
      ),
    );
  }
}