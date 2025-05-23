import 'package:flutter/material.dart';

class AddEditRoutinePage extends StatefulWidget {
  const AddEditRoutinePage({Key? key}) : super(key: key);

  @override
  State<AddEditRoutinePage> createState() => _AddEditRoutinePageState();
}

class _AddEditRoutinePageState extends State<AddEditRoutinePage> {
  String? selectedSector;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Routine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Sector',
                border: OutlineInputBorder(),
              ),
              value: selectedSector,
              items: const [
                DropdownMenuItem(value: 'Diet', child: Text('Diet')),
                DropdownMenuItem(value: 'Gym', child: Text('Gym')),
                DropdownMenuItem(value: 'Finance', child: Text('Finance')),
              ],
              onChanged: (value) => setState(() => selectedSector = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}