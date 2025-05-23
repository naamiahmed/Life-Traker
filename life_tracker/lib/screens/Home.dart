import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, bool> _tasks = {
    'Breakfast': false,
    'Gym': false,
    'Prayer': false,
    'Reading': false,
    'Meditation': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Daily Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Daily Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _tasks.values.where((v) => v).length / _tasks.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks.keys.elementAt(index);
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    title: Text(
                      task,
                      style: TextStyle(
                        decoration: _tasks[task]! ? TextDecoration.lineThrough : null,
                        color: _tasks[task]! ? Colors.grey : Colors.black87,
                      ),
                    ),
                    value: _tasks[task],
                    activeColor: Colors.blue[700],
                    onChanged: (bool? value) {
                      setState(() {
                        _tasks[task] = value!;
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: _tasks[task]! ? Colors.green[100] : Colors.grey[200],
                      child: Icon(
                        _getIconForTask(task),
                        color: _tasks[task]! ? Colors.green : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task functionality
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForTask(String task) {
    switch (task.toLowerCase()) {
      case 'breakfast':
        return Icons.restaurant;
      case 'gym':
        return Icons.fitness_center;
      case 'prayer':
        return Icons.self_improvement;
      case 'reading':
        return Icons.book;
      case 'meditation':
        return Icons.spa;
      default:
        return Icons.check_circle;
    }
  }
}