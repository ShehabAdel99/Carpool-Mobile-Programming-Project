import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_screen.dart';
import 'package:intl/intl.dart';
import 'local_db_helper.dart';



class RouteDetailsScreen extends StatefulWidget {
  final String? rideId;

  RouteDetailsScreen({required this.rideId});

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  Map<String, dynamic>? rideData;
  bool neglectTimeConstraints = false;

  @override
  void initState() {
    super.initState();
    _fetchRideDetails();
  }

  Future<void> _fetchRideDetails() async {
    try {
      DocumentSnapshot ride = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (ride.exists) {
        print('Ride data exists: ${ride.data()}');
        setState(() {
          rideData = ride.data() as Map<String, dynamic>?;
        });
      } else {
        // Ride data doesn't exist
        print('Ride data not found for rideId: ${widget.rideId}');
      }
    } catch (e) {
      print('Error fetching ride details: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (rideData == null) {
      // You can display a loading indicator or an error message here
      return Scaffold(
        appBar: AppBar(
          title: Text('Details'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate back to the HomeScreen when the logo is pressed
            Navigator.pushReplacementNamed(context, '/home');
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
              'Details for ${rideData!['rideName']} ride:',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.0),
            _buildDetailItem('Driver Name', rideData!['driverName']),
            _buildDetailItem('Driver Phone Number', rideData!['driverNumber']),
            _buildDetailItem('Starting Point', rideData!['startLocation']),
            _buildDetailItem('Destination Point', rideData!['destination']),
            _buildDetailItem('Start Ride Time', rideData!['rideDate']+' at '+rideData!['rideTime']),
            _buildDetailItem('Cost', rideData!['rideCost']),
            _buildDetailItem('Reservation Deadline', rideData!['reservationDeadlineDate'] + ' at ' + rideData!['reservationDeadlineTime']),
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
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
            SizedBox(height: 80.0),

            // Toggle Switch for Neglect Time Constraints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Neglect Time Constraints'),
                Switch(
                  value: neglectTimeConstraints,
                  onChanged: (value) {
                    setState(() {
                      neglectTimeConstraints = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$label: ${value ?? 'N/A'}',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  void _bookRoute(BuildContext context) {
    if (rideData!['rideType'] == 'To college') {
      DateTime now = DateTime.now();

      DateTime rideDate = DateFormat('dd/MM/yyyy').parse(rideData!['reservationDeadlineDate']);

      DateTime desiredTime = DateTime(rideDate.year, rideDate.month, rideDate.day, 22, 0);

      print(rideDate);
      print(desiredTime);

      bool isBefore10PM = now.isBefore(desiredTime);
      bool isBeforeRideDate = ( now.day <= rideDate.day && now.month <= rideDate.month && now.year <=rideDate.year);

      print(isBefore10PM);
      print(isBeforeRideDate);


      if (isBefore10PM && isBeforeRideDate) {

        successful_booking(context);

      } else if(neglectTimeConstraints) {

        successful_booking(context);

      }

      else {

        _showErrorNotification(context);
      }
    }
    else if(rideData!['rideType'] == 'Return home'){
      DateTime now = DateTime.now();

      DateTime rideDate = DateFormat('dd/MM/yyyy').parse(rideData!['reservationDeadlineDate']);

      DateTime desiredTime = DateTime(rideDate.year, rideDate.month, rideDate.day, 13, 0);

      bool isBefore1PM = now.isBefore(desiredTime);
      bool isBeforeRideDate = ( now.day <= rideDate.day && now.month <= rideDate.month && now.year <=rideDate.year);

      if (isBefore1PM && isBeforeRideDate) {

        successful_booking(context);

      }else if(neglectTimeConstraints) {

        successful_booking(context);

      } else {

        _showErrorNotification(context);
      }

    }
  }

  Future<void> _saveBookingDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
      String UserId = user.uid;

      final dbHelper = DatabaseHelper();
      final userDetails = await dbHelper.getUserDetails(UserId);


        // Create a request record in the "requests" collection
        await FirebaseFirestore.instance.collection('requests').add({
          'userId': user.uid, // Current Firebase user ID
          'userName': userDetails?['fullName'],
          'userPhone': userDetails?['phoneNumber'],
          'driverId': rideData!['driverId'], // Driver ID from ride details
          'rideId': widget.rideId, // Ride ID
          'status': 'pending', // Initial status
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving booking details: $e');
    }
  }


  void successful_booking(BuildContext context){

    // Save booking details
    _saveBookingDetails();

    _showSuccessNotification(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(bookedRoute: rideData!['rideName']),
      ),
    );

  }


  void _showSuccessNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booked successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You passed the deadline'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}
