import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class NewschedulePage extends StatefulWidget {
  @override
  _NewschedulePageState createState() => _NewschedulePageState();
}

class _NewschedulePageState extends State<NewschedulePage> {
  DateTime? _startDate;     // Start date for scheduling
  DateTime? _endDate;       // End date for scheduling
  TimeOfDay? _selectedTime; // Time for watering each day
  int _timeIntervalInSeconds = 0;  // Duration of watering in seconds
  String _description = ''; // Description field
  int _deviceId = 1;        // Device ID, defaulting to 1
  List<dynamic> _schedules = [];
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    fetchSchedules();
    fetchLogs();
  }

  // Fetch schedules from backend
  Future<void> fetchSchedules() async {
    final response = await http.get(Uri.parse('$baseUrl/schedule'));
    if (response.statusCode == 200) {
      setState(() {
        _schedules = jsonDecode(response.body);
      });
    }
  }

  // Fetch logs from backend
  Future<void> fetchLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/logs'));
    if (response.statusCode == 200) {
      setState(() {
        _logs = jsonDecode(response.body);
      });
    }
  }

  // Function to create a recurring schedule
  Future<void> createSchedule() async {
    if (_startDate != null &&
        _endDate != null &&
        _selectedTime != null &&
        _timeIntervalInSeconds > 0 &&
        _description.isNotEmpty) {
      final startDateTime = DateTime(
        _startDate!.year, _startDate!.month, _startDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      final endDateTime = DateTime(
        _endDate!.year, _endDate!.month, _endDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': _deviceId,
          'start_date': startDateTime.toIso8601String(),
          'end_date': endDateTime.toIso8601String(),
          'time': _selectedTime!.format(context),
          'interval': _timeIntervalInSeconds,
          'description': _description,
        }),
      );

      if (response.statusCode == 201) {
        fetchSchedules(); // Refresh the schedule list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create schedule')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  // Function to select time using time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule Watering")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Device ID Input
            ListTile(
              title: Text('Device ID: $_deviceId'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final String? result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      String input = _deviceId.toString();
                      return AlertDialog(
                        title: Text('Enter Device ID'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) => input = value,
                          decoration: InputDecoration(hintText: 'Device ID'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, input),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  if (result != null) {
                    setState(() {
                      _deviceId = int.tryParse(result) ?? _deviceId;
                    });
                  }
                },
              ),
            ),

            // Start Date Picker
            ListTile(
              title: Text(_startDate == null
                  ? 'Select Start Date'
                  : 'Start Date: ${DateFormat.yMMMd().format(_startDate!)}'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != _startDate) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
            ),

            // End Date Picker
            ListTile(
              title: Text(_endDate == null
                  ? 'Select End Date'
                  : 'End Date: ${DateFormat.yMMMd().format(_endDate!)}'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != _endDate) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
            ),

            // Time Picker
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(_selectedTime == null
                  ? 'Select Time'
                  : 'Selected Time: ${_selectedTime!.format(context)}'),
            ),
            SizedBox(height: 20),

            // Interval Input Field
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Time Interval (in seconds)',
              ),
              onChanged: (value) {
                setState(() {
                  _timeIntervalInSeconds = int.tryParse(value) ?? 0;
                });
              },
            ),

            // Description Input Field
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),

            SizedBox(height: 20),

            // Create Schedule Button
            ElevatedButton(
              onPressed: createSchedule,
              child: Text('Set Recurring Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
