import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<FlSpot> temperatureData = [];
  List<FlSpot> humidityData = [];
  List<FlSpot> moistureData = [];
  List<String> timeLabels = [];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    // Schedule data fetch every 5 minutes
    _timer = Timer.periodic(Duration(minutes: 5), (timer) => fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://iotflower.northeurope.cloudapp.azure.com/iotflower/api/v1/dashboard-data'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      processData(jsonData['data']);
    } else {
      print('Failed to load data');
    }
  }

  void processData(List<dynamic> data) {
      Map<String, Map<String, double>> groupedData = {};

      // Group data by time and associate each field with its value
      for (var item in data) {
        String time = _formatTime(item['time']);
        if (item['value'] != null) {
          double value = (item['value'] as num).toDouble();

          groupedData.putIfAbsent(time, () => {});
          groupedData[time]![item['field']] = value;
        }
      }

      int currentIndex = temperatureData.length; // Start from the current length to avoid overwriting

      groupedData.forEach((time, fields) {
        if (!timeLabels.contains(time)) {
          timeLabels.add(time);

          if (fields.containsKey('temperature')) {
            temperatureData.add(FlSpot(currentIndex.toDouble(), fields['temperature']!));
          }
          if (fields.containsKey('humidity')) {
            humidityData.add(FlSpot(currentIndex.toDouble(), fields['humidity']!));
          }
          if (fields.containsKey('moisture')) {
            moistureData.add(FlSpot(currentIndex.toDouble(), fields['moisture']!));
          }

          currentIndex++;
        }
      });
      setState(() {});
    }


  String _formatTime(String isoTime) {
    DateTime utcTime = DateTime.parse(isoTime).toUtc(); // Parse as UTC
    // Convert to Helsinki time (Europe/Helsinki)
    DateTime helsinkiTime = utcTime.add(Duration(hours: 2)); // Adjust by +2 hours
    // Format the time string
    return DateFormat('HH:mm').format(helsinkiTime);
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
            // Title
            Text(
              'Environmental Data Over Time',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Line Chart
            Expanded(
              child: LineChart(_buildLineChartData()),
            ),

            SizedBox(height: 20),

            // Legend
            _buildLegend(),

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
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < timeLabels.length) {
                return Text(timeLabels[index], style: TextStyle(color: Colors.white, fontSize: 10));
              }
              return Text('');
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}', style: TextStyle(color: Colors.white, fontSize: 12));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      lineBarsData: [
        _buildLineChartBarData(temperatureData, Colors.red),
        _buildLineChartBarData(humidityData, Colors.blue),
        _buildLineChartBarData(moistureData, Colors.green),
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: true),
    );
  }

  // Legend Widget
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(Colors.red, 'Temperature'),
        _legendItem(Colors.blue, 'Humidity'),
        _legendItem(Colors.green, 'Moisture'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
