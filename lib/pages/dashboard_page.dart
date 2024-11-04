import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? temperature;
  double? humidity;

  Future<void> fetchData() async {
    final tempResponse = await http.get(Uri.parse('$baseUrl/temperature'));
    final humResponse = await http.get(Uri.parse('$baseUrl/humidity'));

    setState(() {
      temperature = jsonDecode(tempResponse.body)['temperature'];
      humidity = jsonDecode(humResponse.body)['humidity'];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title and Temperature Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.thermostat, color: Colors.orange, size: 80),
                SizedBox(width: 16),
                Text(
                  'Environmental Data',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Temperature and Humidity Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDataCard('Temperature', '${temperature ?? 'Loading...'} °C'),
                _buildDataCard('Humidity', '${humidity ?? 'Loading...'} %'),
              ],
            ),
            SizedBox(height: 20),

            // Line Chart for Temperature Trends
            Text(
              'Temperature Trends',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(_buildLineChartData()),
            ),

            SizedBox(height: 20),
            // Refresh Button
            ElevatedButton(
              onPressed: fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Refresh Data', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create data card widgets
  Widget _buildDataCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: Colors.lightGreenAccent, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Line chart data configuration
  LineChartData _buildLineChartData() {
    return LineChartData(
      backgroundColor: Colors.black,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[800]!, strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.grey[800]!, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'Jan';
              case 1:
                return 'Feb';
              case 2:
                return 'Mar';
              case 3:
                return 'Apr';
              case 4:
                return 'May';
              case 5:
                return 'Jun';
              default:
                return '';
            }
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitles: (value) {
            return '${value.toInt()}°C';
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      minX: 0,
      maxX: 5,
      minY: 0,
      maxY: 40,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 10),
            FlSpot(1, 15),
            FlSpot(2, 20),
            FlSpot(3, 25),
            FlSpot(4, 30),
            FlSpot(5, 35),
          ],
          isCurved: true,
          colors: [Colors.lightGreenAccent],
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            colors: [Colors.lightGreenAccent.withOpacity(0.3)],
          ),
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }
}
