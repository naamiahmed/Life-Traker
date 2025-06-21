import 'package:flutter/material.dart';
import '../services/TaskService.dart';
import '../services/SectorService.dart';
import '../models/TaskModel.dart';
import '../models/SectorModel.dart';

class DataInitializer {
  static Future<void> initializeDemo() async {
    final taskService = TaskService();
    final sectorService = SectorService();
    
    // Check if data already exists
    final existingSectors = await sectorService.getAllSectors();
    if (existingSectors.isNotEmpty) {
      return; // Demo data already exists
    }
    
    // Create demo sectors
    final demoSectors = [
      SectorModel(
        name: 'Health & Fitness',
        iconName: 'fitness_center',
        colorName: 'blue',
      ),
      SectorModel(
        name: 'Nutrition',
        iconName: 'restaurant_menu',
        colorName: 'green',
      ),
      SectorModel(
        name: 'Finance',
        iconName: 'account_balance_wallet',
        colorName: 'purple',
      ),
      SectorModel(
        name: 'Sleep',
        iconName: 'nightlight_round',
        colorName: 'indigo',
      ),
      SectorModel(
        name: 'Learning',
        iconName: 'school',
        colorName: 'orange',
      ),
    ];
    
    // Add sectors
    for (final sector in demoSectors) {
      await sectorService.addSector(sector);
    }
    
    // Create demo tasks for the last 7 days
    final now = DateTime.now();
    final demoTasks = <TaskModel>[];
    
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = now.subtract(Duration(days: dayOffset));
      
      // Health & Fitness tasks
      demoTasks.addAll([
        TaskModel(
          name: 'Morning workout',
          sector: 'Health & Fitness',
          date: date,
          isDone: dayOffset <= 4, // Completed for last 5 days
          description: '30 minutes cardio and strength training',
          scheduledTime: const TimeOfDay(hour: 7, minute: 0),
        ),
        TaskModel(
          name: 'Evening walk',
          sector: 'Health & Fitness',
          date: date,
          isDone: dayOffset <= 3, // Completed for last 4 days
          description: '20 minutes walk in the park',
          scheduledTime: const TimeOfDay(hour: 18, minute: 30),
        ),
      ]);
      
      // Nutrition tasks
      demoTasks.addAll([
        TaskModel(
          name: 'Drink 8 glasses of water',
          sector: 'Nutrition',
          date: date,
          isDone: dayOffset <= 5, // Completed for last 6 days
          description: 'Stay hydrated throughout the day',
        ),
        TaskModel(
          name: 'Eat 5 servings of fruits/vegetables',
          sector: 'Nutrition',
          date: date,
          isDone: dayOffset <= 2, // Completed for last 3 days
          description: 'Include variety of colors in diet',
        ),
      ]);
      
      // Finance tasks
      if (dayOffset <= 2) { // Only add finance tasks for last 3 days
        demoTasks.addAll([
          TaskModel(
            name: 'Review daily expenses',
            sector: 'Finance',
            date: date,
            isDone: dayOffset <= 1, // Completed for last 2 days
            description: 'Check and categorize spending',
            scheduledTime: const TimeOfDay(hour: 21, minute: 0),
          ),
          TaskModel(
            name: 'Update budget tracker',
            sector: 'Finance',
            date: date,
            isDone: dayOffset == 0, // Only completed today
            description: 'Log income and expenses',
          ),
        ]);
      }
      
      // Sleep tasks
      demoTasks.add(
        TaskModel(
          name: 'Sleep 8 hours',
          sector: 'Sleep',
          date: date,
          isDone: dayOffset <= 4, // Completed for last 5 days
          description: 'Go to bed by 10 PM',
          scheduledTime: const TimeOfDay(hour: 22, minute: 0),
        ),
      );
      
      // Learning tasks
      if (dayOffset <= 4) { // Only add learning tasks for last 5 days
        demoTasks.add(
          TaskModel(
            name: 'Read for 30 minutes',
            sector: 'Learning',
            date: date,
            isDone: dayOffset <= 2, // Completed for last 3 days
            description: 'Read personal development book',
            scheduledTime: const TimeOfDay(hour: 20, minute: 0),
          ),
        );
      }
    }
    
    // Add all demo tasks
    for (final task in demoTasks) {
      await taskService.addTask(task);
    }
  }
  
  static Future<void> clearAllData() async {
    final taskService = TaskService();
    final sectorService = SectorService();
    
    // Clear all tasks
    final tasks = await taskService.getAllTasks();
    for (final task in tasks) {
      await taskService.deleteTask(task);
    }
    
    // Clear all sectors
    final sectors = await sectorService.getAllSectors();
    for (final sector in sectors) {
      await sectorService.deleteSector(sector);
    }
  }
}
