import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/models/TaskModel.dart';
import 'package:life_tracker/screens/Routine.dart';
import 'package:life_tracker/services/TaskService.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskService _taskService = TaskService();
  List<TaskModel> _todaysTasks = [];
  double _completionPercentage = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTodaysTasks();
      final completion = await _taskService.getTodaysCompletion();

      setState(() {
        _todaysTasks = tasks;
        _completionPercentage = completion;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Today\'s Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_completionPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),

                // Tasks List
                Expanded(
                  child: _todaysTasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks for today',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _todaysTasks.length,
                          itemBuilder: (context, index) {
                            final task = _todaysTasks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  task.name,
                                  style: TextStyle(
                                    decoration:
                                        task.isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                subtitle: Text(task.sector),
                                leading: Icon(
                                  _getIconForTask(task.sector),
                                  color: Theme.of(context).primaryColor,
                                ),
                                trailing: Checkbox(
                                  value: task.isDone,
                                  onChanged: (bool? value) async {
                                    if (value != null) {
                                      await _taskService.updateTaskStatus(task, value);
                                      _loadData();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add task page
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditRoutinePage()),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForTask(String sector) {
    switch (sector.toLowerCase()) {
      case 'diet':
        return Icons.restaurant_menu;
      case 'gym':
        return Icons.fitness_center;
      case 'finance':
        return Icons.account_balance_wallet;
      case 'sleep':
        return Icons.nightlight_round;
      default:
        return Icons.check_circle_outline;
    }
  }
}