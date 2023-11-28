import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  // Dummy ride history for demonstration purposes
  final List<RideBooking> rideHistory = [
    RideBooking(
      destination: 'Gate 3',
      startLocation: 'Abdu-Basha',
      rideTime: '7:30 am',
      reservationDeadline: '10:00 pm (Previous day)',
      passengers: 3,
    ),
    RideBooking(
      destination: 'Gate 4',
      startLocation: 'Abbaseya Square',
      rideTime: '5:30 pm',
      reservationDeadline: '1:00 pm (Same day)',
      passengers: 2,
    ),
    // Add more ride bookings as needed
  ];

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
      body: ListView.builder(
        itemCount: rideHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Ride to ${rideHistory[index].destination}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Location: ${rideHistory[index].startLocation}'),
                Text('Ride Time: ${rideHistory[index].rideTime}'),
                Text('Reservation Deadline: ${rideHistory[index].reservationDeadline}'),
                Text('Passengers: ${rideHistory[index].passengers}'),
                // Add more details as needed
              ],
            ),
          );
        },
      ),
    );
  }
}

class RideBooking {
  final String destination;
  final String startLocation;
  final String rideTime;
  final String reservationDeadline;
  final int passengers;

  RideBooking({
    required this.destination,
    required this.startLocation,
    required this.rideTime,
    required this.reservationDeadline,
    required this.passengers,
  });
}
