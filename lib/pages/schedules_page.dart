import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/schedules?device_id=1'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);

        if (decodedBody != null && decodedBody['schedules'] != null && decodedBody['schedules'] is List) {
          setState(() {
            schedules = decodedBody['schedules'];
            isLoading = false;
          });
        } else {
          print('Schedules key is missing or not a list');
          setState(() {
            schedules = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        schedules = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedules')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : schedules.isEmpty
              ? Center(child: Text('No schedules available'))
              : ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date: ${schedule['start_date']}'),
                            Text('End Date: ${schedule['end_date']}'),
                            Text('Time: ${schedule['time']}'),
                            Text('Interval: ${schedule['interval']} seconds'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
