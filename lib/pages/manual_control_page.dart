// lib/pages/manual_control_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ManualControlPage extends StatelessWidget {
  void _activatePump(BuildContext context) async {
    final response = await http.post(Uri.parse('$baseUrl/pump'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pump activated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text('Activate water pump manually', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _activatePump(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text('Activate Pump', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
