import 'package:flutter/material.dart';
import 'package:life_tracker/services/TaskService.dart';
import 'package:life_tracker/models/TaskModel.dart';

class DailyTrackerPage extends StatefulWidget {
  const DailyTrackerPage({Key? key}) : super(key: key);

  @override
  _DailyTrackerPageState createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> _dailyData = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    setState(() => _isLoading = true);
    
    try {
      final List<Map<String, dynamic>> dailyData = [];
      final now = DateTime.now();
      
      // Load last 14 days of data
      for (int i = 0; i < 14; i++) {
        final date = now.subtract(Duration(days: i));
        final tasks = await _taskService.getTasksForDate(date);
        final completed = tasks.where((task) => task.isDone).length;
        final total = tasks.length;
        
        dailyData.add({
          'date': date,
          'tasks': tasks,
          'completed': completed,
          'total': total,
          'formattedDate': _formatDate(date),
        });
      }
      
      setState(() {
        _dailyData = dailyData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load daily data')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(targetDate).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  Future<void> _showTasksForDate(Map<String, dynamic> dayData) async {
    final tasks = dayData['tasks'] as List<TaskModel>;
    final date = dayData['date'] as DateTime;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayData['formattedDate'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No tasks for this day',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.isDone ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(task.sector),
                        trailing: Text(
                          task.scheduledTime != null 
                              ? '${task.scheduledTime!.hour}:${task.scheduledTime!.minute.toString().padLeft(2, '0')}'
                              : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () async {
                          await _taskService.updateTaskStatus(task, !task.isDone);
                          _loadDailyData(); // Refresh data
                          Navigator.pop(context); // Close the modal
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Daily Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDailyData,
          ),
        ],
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
            : _dailyData.isEmpty
                ? const Center(
                    child: Text(
                      'No daily data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dailyData.length,
                    itemBuilder: (context, index) {
                      final dayData = _dailyData[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DailyTrackerCard(
                          date: dayData['formattedDate'],
                          completedTasks: dayData['completed'],
                          totalTasks: dayData['total'],
                          onTap: () => _showTasksForDate(dayData),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add task or create tasks for today
          Navigator.pushNamed(context, '/add-task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DailyTrackerCard extends StatelessWidget {
  final String date;
  final int completedTasks;
  final int totalTasks;
  final VoidCallback? onTap;

  const DailyTrackerCard({
    Key? key,
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final progressColor = progress >= 0.8
        ? Colors.green
        : progress >= 0.5
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completedTasks/$totalTasks done',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),
              if (totalTasks == 0)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No tasks scheduled',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}