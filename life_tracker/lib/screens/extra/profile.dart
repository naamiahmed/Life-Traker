import 'package:flutter/material.dart';
import '../Statistics.dart';
import '../../services/TaskService.dart';
import '../../services/SectorService.dart';
import '../../services/UserService.dart';
import '../../models/UserModel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TaskService _taskService = TaskService();
  final SectorService _sectorService = SectorService();
  final UserService _userService = UserService();
  
  int _totalTasksCompleted = 0;
  int _currentStreak = 0;
  int _totalSectors = 0;
  String _userName = 'Life Tracker User';
  String _profileIconName = 'person';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }
  Future<void> _loadUserStats() async {
    setState(() => _isLoading = true);
    
    try {
      final allTasks = await _taskService.getAllTasks();
      final completedTasks = allTasks.where((task) => task.isDone).length;
      final streak = await _taskService.getCurrentStreak();
      final sectors = await _sectorService.getAllSectors();
      final userData = await _userService.getUserData();

      setState(() {
        _totalTasksCompleted = completedTasks;
        _currentStreak = streak;
        _totalSectors = sectors.length;
        _userName = userData.name;
        _profileIconName = userData.profileIconName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user statistics')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadUserStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [                      const SizedBox(height: 20),
                      // Profile Picture
                      GestureDetector(
                        onTap: _showIconPicker,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Icon(
                            UserModel.getIconFromName(_profileIconName),
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to change icon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // User Name
                      GestureDetector(
                        onTap: _showNameEditor,
                        child: Column(
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to edit name',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status
                      Text(
                        'Keep tracking your progress!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildStatCard(context, 'Tasks\nCompleted', '$_totalTasksCompleted'),
                            _buildStatCard(context, 'Current\nStreak', '$_currentStreak days'),
                            _buildStatCard(context, 'Total\nSectors', '$_totalSectors'),
                          ],
                        ),
                      ),                      const SizedBox(height: 30),
                      // Profile Options
                      _buildProfileOption(
                        context,
                        'Edit Profile',
                        Icons.edit,
                        () {
                          _showEditProfileOptions();
                        },
                      ),
                      _buildProfileOption(
                        context,
                        'View Statistics',
                        Icons.bar_chart,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StatisticsPage()),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        'Refresh Data',
                        Icons.refresh,
                        () {
                          _loadUserStats();
                        },
                      ),
                      _buildProfileOption(
                        context,
                        'App Info',
                        Icons.info,
                        () {
                          _showAppInfo();
                        },
                      ),
                      _buildProfileOption(
                        context,
                        'Help & Tips',
                        Icons.help,
                        () {
                          _showHelpDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
      onTap: onTap,
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Life Tracker'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Life Tracker v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('A comprehensive app to track your daily tasks across different life sectors.'),
            SizedBox(height: 12),
            Text('Features:'),
            SizedBox(height: 4),
            Text('• Create and manage life sectors'),
            Text('• Track daily tasks and progress'),
            Text('• View detailed statistics'),
            Text('• Monitor completion streaks'),
            SizedBox(height: 12),
            Text('Built with Flutter and Hive local storage.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Tips'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Getting Started:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Create sectors for different areas of your life (Health, Finance, etc.)'),
              Text('2. Add daily tasks to each sector'),
              Text('3. Check off completed tasks'),
              Text('4. View your progress in Statistics'),
              SizedBox(height: 16),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Set realistic daily goals'),
              Text('• Use the calendar to track specific dates'),
              Text('• Long press sectors to delete them'),
              Text('• Tap sectors to view and manage tasks'),
              Text('• Maintain an 80% completion rate for streaks'),
              SizedBox(height: 16),
              Text(
                'Demo Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Go to Sectors → Settings to initialize sample data and explore the app features.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Show edit profile options
  void _showEditProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Change Name'),
              onTap: () {
                Navigator.pop(context);
                _showNameEditor();
              },
            ),
            ListTile(
              leading: const Icon(Icons.face),
              title: const Text('Change Profile Icon'),
              onTap: () {
                Navigator.pop(context);
                _showIconPicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show name editor dialog
  void _showNameEditor() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final success = await _userService.updateUserName(newName);
                Navigator.pop(context);
                
                if (success) {
                  setState(() {
                    _userName = newName;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update name')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show icon picker dialog
  void _showIconPicker() {
    final availableIcons = UserModel.getAvailableIcons();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Profile Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = availableIcons[index];
              final isSelected = iconData['name'] == _profileIconName;
              
              return GestureDetector(
                onTap: () async {
                  final success = await _userService.updateProfileIcon(iconData['name']);
                  Navigator.pop(context);
                  
                  if (success) {
                    setState(() {
                      _profileIconName = iconData['name'];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile icon updated!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update icon')),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData['icon'],
                    size: 30,
                    color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
