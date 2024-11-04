// lib/pages/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IoT Irrigation Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_florist, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                'Welcome to IoT Irrigation System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              _buildNavigationButton(
                context,
                'Schedule Watering',
                Icons.schedule,
                '/schedule',
              ),
              _buildNavigationButton(
                context,
                'Manual Pump Control',
                Icons.build,
                '/manual',
              ),
              _buildNavigationButton(
                context,
                'Dashboard',
                Icons.dashboard,
                '/dashboard',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon),
        label: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
