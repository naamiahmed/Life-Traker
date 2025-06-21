import 'package:hive_flutter/hive_flutter.dart';
import '../models/UserModel.dart';

class UserService {
  static const String _boxName = 'user_preferences';
  
  // Get or create box
  Future<Box<UserModel>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<UserModel>(_boxName);
    }
    return Hive.box<UserModel>(_boxName);
  }

  // Get user data (create default if not exists)
  Future<UserModel> getUserData() async {
    final box = await _box;
    if (box.isEmpty) {
      final defaultUser = UserModel(name: 'Life Tracker User');
      await box.add(defaultUser);
      return defaultUser;
    }
    return box.values.first;
  }

  // Update user name
  Future<bool> updateUserName(String name) async {
    try {
      final user = await getUserData();
      user.name = name;
      await user.save();
      return true;
    } catch (e) {
      print('Error updating user name: $e');
      return false;
    }
  }

  // Update profile icon
  Future<bool> updateProfileIcon(String iconName) async {
    try {
      final user = await getUserData();
      user.profileIconName = iconName;
      await user.save();
      return true;
    } catch (e) {
      print('Error updating profile icon: $e');
      return false;
    }
  }

  // Clear user data
  Future<bool> clearUserData() async {
    try {
      final box = await _box;
      await box.clear();
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }
}
