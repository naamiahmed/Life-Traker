import 'package:flutter/material.dart';
import 'package:life_tracker/services/TaskService.dart';

class SectorOverviewPage extends StatefulWidget {
  const SectorOverviewPage({Key? key}) : super(key: key);

  @override
  _SectorOverviewPageState createState() => _SectorOverviewPageState();
}

class _SectorOverviewPageState extends State<SectorOverviewPage> {
  final TaskService _taskService = TaskService();
  Map<String, double> _sectorProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSectorProgress();
  }

  Future<void> _loadSectorProgress() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final progress = await _taskService.getSectorCompletionRates();

      if (!mounted) return;

      setState(() {
        _sectorProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load sector progress')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Life Sectors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Add settings functionality
            },
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
            : _sectorProgress.isEmpty
                ? const Center(child: Text('No sector progress found'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: _sectorProgress.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final sector = _sectorProgress.keys.elementAt(index);
                        final progress = _sectorProgress[sector] ?? 0.0;
                        return _buildSectorCard(
                          context,
                          sector,
                          _getIconForSector(sector),
                          _getColorForSector(sector),
                          '${(progress * 100).toStringAsFixed(0)}%',
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new sector functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectorCard(BuildContext context, String title, IconData icon,
      Color color, String progress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to sector detail
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  progress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSector(String sector) {
    switch (sector) {
      case 'Diet':
        return Icons.restaurant_menu;
      case 'Gym':
        return Icons.fitness_center;
      case 'Finance':
        return Icons.account_balance_wallet;
      case 'Sleep':
        return Icons.nightlight_round;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForSector(String sector) {
    switch (sector) {
      case 'Diet':
        return Colors.green.shade400;
      case 'Gym':
        return Colors.blue.shade400;
      case 'Finance':
        return Colors.purple.shade400;
      case 'Sleep':
        return Colors.indigo.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}