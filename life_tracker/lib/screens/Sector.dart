import 'package:flutter/material.dart';
import 'package:life_tracker/services/TaskService.dart';
import 'package:life_tracker/services/SectorService.dart';
import 'package:life_tracker/models/SectorModel.dart';
import 'package:life_tracker/screens/Settings.dart';

class SectorOverviewPage extends StatefulWidget {
  const SectorOverviewPage({Key? key}) : super(key: key);

  @override
  _SectorOverviewPageState createState() => _SectorOverviewPageState();
}

class _SectorOverviewPageState extends State<SectorOverviewPage> {
  final TaskService _taskService = TaskService();
  final SectorService _sectorService = SectorService();
  List<SectorModel> _sectors = [];
  Map<String, double> _sectorProgress = {};
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _sectorNameController = TextEditingController();
  String? _selectedIconName;
  String? _selectedColorName;

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  Future<void> _loadSectors() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final sectors = await _sectorService.getAllSectors();
      final progress = await _taskService.getSectorCompletionRates();

      if (!mounted) return;

      setState(() {
        _sectors = sectors;
        _sectorProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load sectors')),
      );
    }
  }

  Future<void> _showAddSectorDialog() async {
    _sectorNameController.clear();
    _selectedIconName = null;
    _selectedColorName = null;
    
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Sector'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _sectorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Sector Name',
                      hintText: 'Enter sector name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a sector name';
                      }
                      if (_sectors.any((s) => s.name == value)) {
                        return 'This sector already exists';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Icon'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SectorService.getAvailableIcons().map((iconData) {
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedIconName = iconData['name'] as String);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedIconName == iconData['name']
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : null,
                            border: Border.all(
                              color: _selectedIconName == iconData['name']
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(iconData['icon'] as IconData),
                              const SizedBox(height: 4),
                              Text(
                                iconData['label'] as String,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SectorService.getAvailableColors().map((colorData) {
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedColorName = colorData['name'] as String);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorData['color'] as Color,
                            border: Border.all(
                              color: _selectedColorName == colorData['name']
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_selectedIconName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an icon')),
                    );
                    return;
                  }
                  if (_selectedColorName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a color')),
                    );
                    return;
                  }

                  final newSector = SectorModel(
                    name: _sectorNameController.text,
                    iconName: _selectedIconName!,
                    colorName: _selectedColorName!,
                  );

                  final success = await _sectorService.addSector(newSector);
                  
                  if (!mounted) return;
                  
                  if (success) {
                    Navigator.pop(context);
                    _loadSectors();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sector "${newSector.name}" created')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create sector')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(SectorModel sector) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sector'),
        content: Text('Are you sure you want to delete the "${sector.name}" sector?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await _sectorService.deleteSector(sector);
              
              if (!mounted) return;
              
              if (success) {
                Navigator.pop(context);
                _loadSectors();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sector "${sector.name}" deleted')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete sector')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  Future<void> _navigateToSectorDetail(SectorModel sector) async {
    // Get tasks for this sector
    final allTasks = await _taskService.getAllTasks();
    final sectorTasks = allTasks.where((task) => task.sector == sector.name).toList();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SectorService.getColorFromName(sector.colorName),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        SectorService.getIconFromName(sector.iconName),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sector.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${sectorTasks.length} tasks',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Tasks list
              Expanded(
                child: sectorTasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks in this sector',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: sectorTasks.length,
                        itemBuilder: (context, index) {
                          final task = sectorTasks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isDone,
                                onChanged: (value) async {
                                  await _taskService.updateTaskStatus(task, value ?? false);
                                  _loadSectors(); // Refresh the sector progress
                                  Navigator.pop(context);
                                  _navigateToSectorDetail(sector); // Reopen with updated data
                                },
                              ),
                              title: Text(
                                task.name,
                                style: TextStyle(
                                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                                  color: task.isDone ? Colors.grey : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${task.date.day}/${task.date.month}/${task.date.year}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (task.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description!,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                  if (task.scheduledTime != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Time: ${task.scheduledTime!.format(context)}',
                                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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
          'Life Sectors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
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
            : _sectors.isEmpty
                ? const Center(child: Text('No sectors found'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: _sectors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final sector = _sectors[index];
                        final progress = _sectorProgress[sector.name] ?? 0.0;
                        return _buildSectorCard(
                          context,
                          sector,
                          progress,
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSectorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectorCard(BuildContext context, SectorModel sector, double progress) {
    final color = SectorService.getColorFromName(sector.colorName);
    final icon = SectorService.getIconFromName(sector.iconName);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),      child: InkWell(
        onTap: () {
          // Navigate to sector detail with tasks
          _navigateToSectorDetail(sector);
        },
        onLongPress: () => _showDeleteConfirmation(sector),
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
                sector.name,
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
                  '${(progress * 100).toStringAsFixed(0)}%',
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
    );  }
  @override
  void dispose() {
    _sectorNameController.dispose();
    super.dispose();
  }
}