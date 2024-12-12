import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package for date formatting
import '../constants.dart'; // Ensure this contains the correct baseUrl

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<dynamic> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      // Correct the endpoint for logs
      final response = await http.get(Uri.parse('$baseUrl/logs?device_id=1'));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);

        if (decodedBody != null && decodedBody['logs'] != null && decodedBody['logs'] is List) {
          setState(() {
            logs = decodedBody['logs'];
            isLoading = false;
          });
        } else {
          print('Logs key is missing or not a list');
          setState(() {
            logs = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        logs = [];
        isLoading = false;
      });
    }
  }

  // Function to format and adjust the time
  String formatLogTime(String createdAt) {
    try {
      DateTime utcTime = DateTime.parse(createdAt);
      DateTime helsinkiTime = utcTime.add(Duration(hours: 2));

      // Format the date as "Dec 10 12:56"
      return DateFormat('MMM dd HH:mm').format(helsinkiTime);
    } catch (e) {
      print('Time parsing error: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logs')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? Center(child: Text('No logs available'))
              : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading: Icon(Icons.event_note, color: Colors.blue),
                        title: Text('Action: ${log['action']}'),
                        subtitle: Text('Time: ${formatLogTime(log['createdAt'])}'),
                      ),
                    );
                  },
                ),
    );
  }
}
