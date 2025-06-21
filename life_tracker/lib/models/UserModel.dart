import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'UserModel.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String profileIconName;

  UserModel({
    required this.name,
    this.profileIconName = 'person',
  });

  // Available profile icons
  static List<Map<String, dynamic>> getAvailableIcons() {
    return [
      {'name': 'person', 'icon': Icons.person, 'label': 'Default'},
      {'name': 'account_circle', 'icon': Icons.account_circle, 'label': 'Circle'},
      {'name': 'face', 'icon': Icons.face, 'label': 'Face'},
      {'name': 'person_outline', 'icon': Icons.person_outline, 'label': 'Outline'},
      {'name': 'accessibility', 'icon': Icons.accessibility, 'label': 'Accessibility'},
      {'name': 'star', 'icon': Icons.star, 'label': 'Star'},
      {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Heart'},
      {'name': 'emoji_emotions', 'icon': Icons.emoji_emotions, 'label': 'Happy'},
    ];
  }

  // Get icon data from name
  static IconData getIconFromName(String name) {
    final icon = getAvailableIcons().firstWhere(
      (element) => element['name'] == name,
      orElse: () => {'name': 'person', 'icon': Icons.person, 'label': 'Default'},
    )['icon'] as IconData;
    return icon;
  }
}
