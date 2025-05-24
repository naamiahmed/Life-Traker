import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import '../models/TaskModel.dart';

class TaskService {
  static const String _boxName = 'tasks';
  
  // Get or create box
  Future<Box<TaskModel>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<TaskModel>(_boxName);
    }
    return Hive.box<TaskModel>(_boxName);
  }

  // Add a new task with error handling
  Future<bool> addTask(TaskModel task) async {
    try {
      final box = await _box;
      await box.add(task);
      return true;
    } catch (e) {
      print('Error saving task: $e'); // For debugging
      return false;
    }
  }

  // Get today's tasks
  Future<List<TaskModel>> getTodaysTasks() async {
    final box = await _box;
    final now = DateTime.now();
    return box.values.where((task) =>
      task.date.year == now.year &&
      task.date.month == now.month &&
      task.date.day == now.day
    ).toList();
  }

  // Get today's completion percentage
  Future<double> getTodaysCompletion() async {
    final tasks = await getTodaysTasks();
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isDone).length;
    return (completedTasks / tasks.length) * 100;
  }

  // Update task status
  Future<void> updateTaskStatus(TaskModel task, bool isDone) async {
    task.isDone = isDone;
    await task.save();
  }

  // Get sector completion rates
  Future<Map<String, double>> getSectorCompletionRates() async {
    final box = await _box;
    final tasks = box.values.toList();
    
    if (tasks.isEmpty) {
      return {
        'Diet': 0.0,
        'Gym': 0.0,
        'Finance': 0.0,
        'Sleep': 0.0,
      };
    }

    Map<String, List<TaskModel>> tasksBySector = {};
    for (var task in tasks) {
      if (!tasksBySector.containsKey(task.sector)) {
        tasksBySector[task.sector] = [];
      }
      tasksBySector[task.sector]!.add(task);
    }

    Map<String, double> completionRates = {};
    tasksBySector.forEach((sector, sectorTasks) {
      if (sectorTasks.isEmpty) {
        completionRates[sector] = 0.0;
      } else {
        final completed = sectorTasks.where((task) => task.isDone).length;
        completionRates[sector] = completed / sectorTasks.length;
      }
    });

    return completionRates;
  }
}