import 'package:flutter/material.dart';
import '../Statistics.dart';
import '../../services/TaskService.dart';
import '../../services/SectorService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TaskService _taskService = TaskService();
  final SectorService _sectorService = SectorService();
  
  int _totalTasksCompleted = 0;
  int _currentStreak = 0;
  int _totalSectors = 0;
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

      setState(() {
        _totalTasksCompleted = completedTasks;
        _currentStreak = streak;
        _totalSectors = sectors.length;
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
                    children: [
                      const SizedBox(height: 20),
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // User Name
                      const Text(
                        'Life Tracker User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status
                      Text(
                        'Keep tracking your progress!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
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
                      ),
                      const SizedBox(height: 30),
                      // Profile Options
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
                  color: Colors.grey[600],
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
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
      ),      onTap: onTap,
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
}
