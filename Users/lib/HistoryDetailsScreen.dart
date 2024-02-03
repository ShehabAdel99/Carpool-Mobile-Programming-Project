import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class HistoryDetailsScreen extends StatefulWidget {
  final String? rideId;
  final String? rideStatus;


  HistoryDetailsScreen({required this.rideId,required this.rideStatus});

  @override
  _HistoryDetailsScreenState createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
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
          title: Text('History Details:'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.history_outlined,
                color: Color(0xFF1267F8),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/history');
              },
            ),
            Spacer(flex: 2),
            GestureDetector(
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
            Spacer(flex: 1),
            Spacer(flex: 2),
          ],
        ),
        centerTitle: false,
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
            _buildDetailItem('Start Ride Time',
                rideData!['rideDate'] + ' at ' + rideData!['rideTime']),
            _buildDetailItem('Cost', rideData!['rideCost']),
            _buildDetailItem('Reservation Deadline',
                rideData!['reservationDeadlineDate'] + ' at ' +
                    rideData!['reservationDeadlineTime']),
            SizedBox(height: 10.0),
            _buildDetailItem('Status', ' ${widget.rideStatus}'),
            SizedBox(height: 20.0),

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

}