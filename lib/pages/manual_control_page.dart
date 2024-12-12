import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import '../constants.dart'; // Ensure this contains your `baseUrl`

class ManualControlPage extends StatefulWidget {
  @override
  _ManualControlPageState createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  bool _isPumpActive = false; // Track pump status
  bool _isLoading = false; // Track loading state
  TextEditingController _timeController = TextEditingController(); // Controller for time input

  // Function to fetch the current pump status
  Future<void> _fetchPumpStatus() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/pump-status?device_id=1')); 
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _isPumpActive = data['activate']);
      } else {
        _showSnackbar('Failed to fetch pump status');
      }
    } catch (e) {
      _showSnackbar('Error fetching pump status');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to activate the pump with a time interval
  Future<void> _activatePump() async {
    final String timeInterval = _timeController.text;

    if (timeInterval.isEmpty || int.tryParse(timeInterval) == null) {
      _showSnackbar('Please enter a valid time interval (in seconds)');
      return;
    }

    setState(() => _isLoading = true);
    try {
        final response = await http.post(
          Uri.parse('$baseUrl/set-pump-status'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'device_id': 1,
            'status': 'active',
            'interval': int.tryParse(_timeController.text) ?? 5, // Ensure valid input
          }),
        );
      if (response.statusCode == 200) {
        setState(() => _isPumpActive = true);
        _showSnackbar('Pump activated for $timeInterval seconds!');
      } else {
        _showSnackbar('Failed to activate pump');
        
      }
    } catch (e) {
      _showSnackbar('Error activating pump');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to show a snackbar message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _fetchPumpStatus(); // Fetch the initial pump status when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Control')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPumpActive ? Icons.power : Icons.power_off,
                    color: _isPumpActive ? Colors.green : Colors.red,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _isPumpActive ? 'Pump is currently ON' : 'Pump is currently OFF',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter time interval (seconds)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _activatePump,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'Activate Pump',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
