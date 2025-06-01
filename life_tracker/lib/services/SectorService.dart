import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import '../models/SectorModel.dart';

class SectorService {
  static const String _boxName = 'sectors';
  
  // Get or create box
  Future<Box<SectorModel>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<SectorModel>(_boxName);
    }
    return Hive.box<SectorModel>(_boxName);
  }

  // Add a new sector
  Future<bool> addSector(SectorModel sector) async {
    try {
      final box = await _box;
      await box.add(sector);
      return true;
    } catch (e) {
      print('Error saving sector: $e');
      return false;
    }
  }

  // Get all sectors
  Future<List<SectorModel>> getAllSectors() async {
    final box = await _box;
    return box.values.toList();
  }

  // Delete a sector
  Future<bool> deleteSector(SectorModel sector) async {
    try {
      await sector.delete();
      return true;
    } catch (e) {
      print('Error deleting sector: $e');
      return false;
    }
  }

  // Get available icons
  static List<Map<String, dynamic>> getAvailableIcons() {
    return [
      {'name': 'restaurant_menu', 'icon': Icons.restaurant_menu, 'label': 'Food'},
      {'name': 'fitness_center', 'icon': Icons.fitness_center, 'label': 'Fitness'},
      {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet, 'label': 'Finance'},
      {'name': 'nightlight_round', 'icon': Icons.nightlight_round, 'label': 'Sleep'},
      {'name': 'school', 'icon': Icons.school, 'label': 'Education'},
      {'name': 'work', 'icon': Icons.work, 'label': 'Work'},
      {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Health'},
      {'name': 'sports_esports', 'icon': Icons.sports_esports, 'label': 'Gaming'},
      {'name': 'book', 'icon': Icons.book, 'label': 'Reading'},
      {'name': 'music_note', 'icon': Icons.music_note, 'label': 'Music'},
    ];
  }

  // Get available colors
  static List<Map<String, dynamic>> getAvailableColors() {
    return [
      {'name': 'green', 'color': Colors.green},
      {'name': 'blue', 'color': Colors.blue},
      {'name': 'purple', 'color': Colors.purple},
      {'name': 'indigo', 'color': Colors.indigo},
      {'name': 'red', 'color': Colors.red},
      {'name': 'orange', 'color': Colors.orange},
      {'name': 'pink', 'color': Colors.pink},
      {'name': 'teal', 'color': Colors.teal},
      {'name': 'cyan', 'color': Colors.cyan},
      {'name': 'amber', 'color': Colors.amber},
    ];
  }

  // Get icon data from name
  static IconData getIconFromName(String name) {
    final icon = getAvailableIcons().firstWhere(
      (element) => element['name'] == name,
      orElse: () => {'name': 'help_outline', 'icon': Icons.help_outline, 'label': 'Default'},
    )['icon'] as IconData;
    return icon;
  }

  // Get color from name
  static Color getColorFromName(String name) {
    final color = getAvailableColors().firstWhere(
      (element) => element['name'] == name,
      orElse: () => {'name': 'grey', 'color': Colors.grey},
    )['color'] as Color;
    return color;
  }
} 