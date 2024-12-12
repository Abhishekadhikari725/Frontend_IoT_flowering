import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _timeIntervalInSeconds = 0; // Time interval for the pump to run in seconds
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

  // Function to create a schedule with date, time, and interval
  Future<void> createSchedule() async {
    if (_selectedDate != null && _selectedTime != null && _timeIntervalInSeconds > 0) {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': 1,  // Assume device_id is 1, adjust as necessary
          'start_time': dateTime.toIso8601String(),
          'interval': _timeIntervalInSeconds, // Duration in seconds
          'description': 'Water Scheduled'
        }),
      );

      if (response.statusCode == 201) {
        fetchSchedules(); // Refresh the schedule list
      }
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
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectTime(context),
            child: Text(_selectedTime == null
                ? 'Select Time'
                : 'Selected Time: ${_selectedTime!.format(context)}'),
          ),
          SizedBox(height: 20),
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
          ElevatedButton(
            onPressed: createSchedule,
            child: Text('Set Schedule'),
          ),
          Expanded(
            child: ListView(
              children: [
                Text("Scheduled Events:", style: TextStyle(fontSize: 18)),
                ..._schedules.map((schedule) => ListTile(
                  title: Text('Scheduled at: ${schedule['start_time']}'),
                  subtitle: Text('Duration: ${schedule['duration']} seconds'),
                )),
                SizedBox(height: 20),
                Text("Log History:", style: TextStyle(fontSize: 18)),
                ..._logs.map((log) => ListTile(
                  title: Text(log['action']),
                  subtitle: Text(log['timestamp']),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

