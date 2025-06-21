import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_tracker/services/TaskService.dart';
import 'package:life_tracker/services/SectorService.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final TaskService _taskService = TaskService();
  
  bool _isLoading = true;
  Map<String, dynamic> _statsData = {};
  List<Map<String, dynamic>> _weeklyData = [];
  Map<String, double> _sectorPerformance = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all statistics data
      final weeklyTasks = await _taskService.getWeeklyTasks();
      final completedWeekly = weeklyTasks.where((task) => task.isDone).length;
      final streak = await _taskService.getCurrentStreak();
      final focusTime = await _taskService.getWeeklyFocusTime();
      final productivityTrend = await _taskService.getProductivityTrend();
      final weeklyCompletionData = await _taskService.getWeeklyCompletionData();
      final sectorPerformance = await _taskService.getSectorPerformanceLast30Days();

      setState(() {
        _statsData = {
          'weeklyCompleted': completedWeekly,
          'weeklyTotal': weeklyTasks.length,
          'streak': streak,
          'focusTime': focusTime,
          'productivityTrend': productivityTrend,
        };
        _weeklyData = weeklyCompletionData;
        _sectorPerformance = sectorPerformance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load statistics')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Statistics',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCards(),
                    const SizedBox(height: 24),
                    _buildWeeklyChart(context),
                    const SizedBox(height: 24),
                    _buildSectorPerformance(),
                  ],
                ),
              ),
      ),
    );
  }
  Widget _buildStatCards() {
    final weeklyCompleted = _statsData['weeklyCompleted'] ?? 0;
    final weeklyTotal = _statsData['weeklyTotal'] ?? 0;
    final streak = _statsData['streak'] ?? 0;
    final focusTime = _statsData['focusTime'] ?? 0.0;
    final productivityTrend = _statsData['productivityTrend'] ?? 0.0;
    
    final weeklyPercentage = weeklyTotal > 0 ? ((weeklyCompleted / weeklyTotal) * 100).round() : 0;
    final trendText = productivityTrend > 0 
        ? '↑ ${productivityTrend.toStringAsFixed(1)}% from last week'
        : productivityTrend < 0 
            ? '↓ ${(-productivityTrend).toStringAsFixed(1)}% from last week'
            : 'Same as last week';
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Weekly Tasks',
          '$weeklyCompleted/$weeklyTotal',
          Icons.check_circle,
          Colors.green,
          '$weeklyPercentage% Complete',
        ),
        _buildStatCard(
          'Current Streak',
          '$streak Days',
          Icons.local_fire_department,
          Colors.orange,
          streak > 7 ? 'Great job!' : 'Keep going!',
        ),
        _buildStatCard(
          'Focus Time',
          '${focusTime.toStringAsFixed(1)} hrs',
          Icons.timer,
          Colors.blue,
          'This Week',
        ),
        _buildStatCard(
          'Productivity',
          '$weeklyPercentage%',
          Icons.trending_up,
          productivityTrend >= 0 ? Colors.purple : Colors.red,
          trendText,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding from 16 to 12
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24), // Reduced size from 30 to 24
            const SizedBox(height: 4), // Reduced from 8 to 4
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20, // Reduced from 24
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13, // Reduced from 14
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11, // Reduced from 12
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWeeklyChart(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _weeklyData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < _weeklyData.length) {
                                  return Text(
                                    _weeklyData[index]['dayName'],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _weeklyData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final percentage = data['percentage'] / 100;
                              return FlSpot(index.toDouble(), percentage * 6); // Scale to 0-6 for better visibility
                            }).toList(),
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 6,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSectorPerformance() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sector Performance (Last 30 Days)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_sectorPerformance.isEmpty)
              const Center(
                child: Text(
                  'No sector data available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._sectorPerformance.entries.map((entry) {
                final color = _getSectorColor(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSectorProgressBar(entry.key, entry.value, color),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getSectorColor(String sectorName) {
    // Try to get color from SectorService if available
    try {
      final sectors = SectorService.getAvailableColors();
      final colorIndex = sectorName.hashCode % sectors.length;
      return sectors[colorIndex]['color'] as Color;
    } catch (e) {
      // Fallback colors
      switch (sectorName.toLowerCase()) {
        case 'diet':
        case 'food':
          return Colors.green;
        case 'gym':
        case 'fitness':
          return Colors.blue;
        case 'finance':
          return Colors.purple;
        case 'sleep':
          return Colors.indigo;
        case 'work':
          return Colors.orange;
        case 'education':
          return Colors.teal;
        default:
          return Colors.grey;
      }
    }
  }

  Widget _buildSectorProgressBar(String sector, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sector,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}