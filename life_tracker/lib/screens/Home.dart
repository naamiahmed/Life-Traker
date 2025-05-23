import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today - May 23'),
      ),
      body: ListView(
        children: [
          CheckboxListTile(
            title: const Text('Breakfast'),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: const Text('Gym'),
            value: false,
            onChanged: (bool? value) {},
          ),
          CheckboxListTile(
            title: const Text('Prayer'),
            value: false,
            onChanged: (bool? value) {},
          ),
        ],
      ),
    );
  }
}