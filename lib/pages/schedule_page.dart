import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime? _selectedDate;
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

  // Create a new schedule
  Future<void> createSchedule() async {
    if (_selectedDate != null) {
      final response = await http.post(
        Uri.parse('$baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': _selectedDate!.toIso8601String(),
          'description': 'Watering scheduled',
        }),
      );

      if (response.statusCode == 201) {
        fetchSchedules(); // Refresh the schedule list
      }
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
          ElevatedButton(
            onPressed: createSchedule,
            child: Text('Set Schedule'),
          ),
          Expanded(
            child: ListView(
              children: [
                Text("Scheduled Events:", style: TextStyle(fontSize: 18)),
                ..._schedules.map((schedule) => ListTile(
                  title: Text(schedule['description']),
                  subtitle: Text(schedule['date']),
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
