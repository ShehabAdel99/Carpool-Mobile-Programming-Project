import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'home_screen.dart'; // Import the HomeScreen

class RouteDetailsScreen extends StatelessWidget {
  final String routeName;

  RouteDetailsScreen(this.routeName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate back to the HomeScreen when the logo is pressed
            Navigator.pop(context);
          },
          child: Image.asset(
            'assets/images/carpool_icon.png',
            width: 60.0,
            height: 60.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Details for $routeName',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.0),
            _buildDetailItem('Starting Point', 'Nasr City'),
            _buildDetailItem('Destination Point', 'Gate 3 '),
            _buildDetailItem('Start Ride Time', '7:30 am'),
            _buildDetailItem('Reservation Deadline', '10:00 pm'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Add logic to book the route
                _bookRoute(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF1267F8), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: Text(
                'Book This Route',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _bookRoute(BuildContext context) {
    // Add logic to book the route


    // For now, let's assume it's booked successfully
    _showSuccessNotification(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen(bookedRoute: routeName)),
    );
  }

  void _showSuccessNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booked successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
