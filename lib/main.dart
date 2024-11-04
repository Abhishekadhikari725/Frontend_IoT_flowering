// main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/schedule_page.dart';
import 'pages/manual_control_page.dart';
import 'pages/dashboard_page.dart';

void main() => runApp(IotIrrigationApp());

class IotIrrigationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Irrigation System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: Colors.lightGreen, // This replaces the old `accentColor`
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green,
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/schedule': (context) => SchedulePage(),
        '/manual': (context) => ManualControlPage(),
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}
