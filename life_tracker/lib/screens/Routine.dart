import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditRoutinePage extends StatefulWidget {
  const AddEditRoutinePage({Key? key}) : super(key: key);

  @override
  State<AddEditRoutinePage> createState() => _AddEditRoutinePageState();
}

class _AddEditRoutinePageState extends State<AddEditRoutinePage> {
  String? selectedSector;
  TimeOfDay? selectedTime;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Create Routine',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(
                  label: 'Task Name',
                  icon: Icons.task_alt,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a task name' : null,
                ),
                const SizedBox(height: 20),
                _buildSectorDropdown(),
                const SizedBox(height: 20),
                _buildTimePickerField(context),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Routine',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectorDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSector,
      validator: (value) =>
          value == null ? 'Please select a sector' : null,
      decoration: InputDecoration(
        labelText: 'Sector',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
      items: const [
        DropdownMenuItem(value: 'Diet', child: Text('Diet 🍎')),
        DropdownMenuItem(value: 'Gym', child: Text('Gym 💪')),
        DropdownMenuItem(value: 'Finance', child: Text('Finance 💰')),
        DropdownMenuItem(value: 'Sleep', child: Text('Sleep 😴')),
      ],
      onChanged: (value) => setState(() => selectedSector = value),
    );
  }

  Widget _buildTimePickerField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => selectedTime = time);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        child: Text(
          selectedTime?.format(context) ?? 'Select Time',
          style: TextStyle(
            color: selectedTime == null ? Colors.grey.shade600 : Colors.black,
          ),
        ),
      ),
    );
  }

  void _saveRoutine() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save functionality
      Navigator.pop(context);
    }
  }
}