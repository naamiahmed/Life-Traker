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
  // Get tasks for a specific date
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final box = await _box;
    return box.values.where((task) =>
      task.date.year == date.year &&
      task.date.month == date.month &&
      task.date.day == date.day
    ).toList();
  }

  // Get tasks for a date range
  Future<List<TaskModel>> getTasksInRange(DateTime startDate, DateTime endDate) async {
    final box = await _box;
    return box.values.where((task) =>
      task.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      task.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  // Get weekly tasks (last 7 days)
  Future<List<TaskModel>> getWeeklyTasks() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    return await getTasksInRange(weekAgo, now);
  }

  // Get daily completion data for last 7 days
  Future<List<Map<String, dynamic>>> getWeeklyCompletionData() async {
    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final tasks = await getTasksForDate(date);
      final completed = tasks.where((task) => task.isDone).length;
      final total = tasks.length;
      
      weeklyData.add({
        'date': date,
        'completed': completed,
        'total': total,
        'percentage': total > 0 ? (completed / total) * 100 : 0.0,
        'dayName': _getDayName(date.weekday),
      });
    }
    
    return weeklyData;
  }

  // Get streak information
  Future<int> getCurrentStreak() async {
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Max check 1 year
      final date = now.subtract(Duration(days: i));
      final tasks = await getTasksForDate(date);
      
      if (tasks.isEmpty) {
        break; // No tasks for this day, streak broken
      }
      
      final completionRate = tasks.where((task) => task.isDone).length / tasks.length;
      if (completionRate >= 0.8) { // 80% completion considered successful day
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // Get focus time (estimate based on completed tasks)
  Future<double> getWeeklyFocusTime() async {
    final weeklyTasks = await getWeeklyTasks();
    final completedTasks = weeklyTasks.where((task) => task.isDone).length;
    return completedTasks * 0.5; // Assume 30 minutes per completed task
  }

  // Get productivity trend (week over week)
  Future<double> getProductivityTrend() async {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    
    final thisWeekTasks = await getTasksInRange(thisWeekStart, now);
    final lastWeekTasks = await getTasksInRange(lastWeekStart, thisWeekStart.subtract(const Duration(days: 1)));
    
    final thisWeekCompletion = thisWeekTasks.isEmpty ? 0.0 : 
        thisWeekTasks.where((task) => task.isDone).length / thisWeekTasks.length;
    final lastWeekCompletion = lastWeekTasks.isEmpty ? 0.0 : 
        lastWeekTasks.where((task) => task.isDone).length / lastWeekTasks.length;
    
    if (lastWeekCompletion == 0) return 0.0;
    return ((thisWeekCompletion - lastWeekCompletion) / lastWeekCompletion) * 100;
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  // Get sector completion rates
  Future<Map<String, double>> getSectorCompletionRates() async {
    final box = await _box;
    final tasks = box.values.toList();
    
    if (tasks.isEmpty) {
      return {};
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

  // Get sector performance for last 30 days
  Future<Map<String, double>> getSectorPerformanceLast30Days() async {
    final monthlyTasks = await getTasksInRange(
      DateTime.now().subtract(const Duration(days: 29)), 
      DateTime.now()
    );
    
    if (monthlyTasks.isEmpty) {
      return {};
    }

    Map<String, List<TaskModel>> tasksBySector = {};
    for (var task in monthlyTasks) {
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

  // Delete a task
  Future<bool> deleteTask(TaskModel task) async {
    try {
      await task.delete();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    final box = await _box;
    return box.values.toList();
  }
}