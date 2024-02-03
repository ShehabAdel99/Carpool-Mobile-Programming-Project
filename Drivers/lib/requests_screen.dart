import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  final String? rideId;

  RequestsScreen({required this.rideId});

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  Map<String, dynamic>? rideData;
  List<String> usersRequests = [];
  List<String> filteredRequests = [];
  late String driverId;
  late String? RideID = widget.rideId;
  TextEditingController _searchController = TextEditingController();
  bool neglectTimeConstraints = false;
  bool finishRides = false;

  @override
  void initState() {
    super.initState();
    _getDriverId();
    _fetchRideDetails();
    _fetchUsersRequestsRoutes();
  }

  Future<void> _getDriverId() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        driverId = user.uid;
      });
    }
  }

  Future<void> _fetchRideDetails() async {
    try {
      DocumentSnapshot ride = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (ride.exists) {
        setState(() {
          rideData = ride.data() as Map<String, dynamic>?;
        });
      } else {
        print('Ride data not found for rideId: ${widget.rideId}');
      }
    } catch (e) {
      print('Error fetching ride details: $e');
    }
  }

  Future<void> _fetchUsersRequestsRoutes() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('rideId', isEqualTo: RideID)
          .where('driverId', isEqualTo: driverId)
          .get();
      usersRequests =
          querySnapshot.docs.map((doc) => doc['userName'] as String).toList();

      print(usersRequests);
    } catch (e) {
      print('Error fetching users requests: $e');
    }
  }

  void filterUsersRequests(String query) {
    setState(() {
      filteredRequests = _filteredUsersRequests(query);
    });
  }

  List<String> _filteredUsersRequests(String query) {
    return usersRequests
        .where((userName) => userName.toLowerCase().contains(query))
        .toList();
  }

  // Inside the build method
  @override
  Widget build(BuildContext context) {
    if (rideData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Requests'),
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
      body: Column(
        children: [
          SizedBox(height: 20.0),
          Text(
            'Your Requests: ',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                filterUsersRequests(value);
              },
              decoration: InputDecoration(
                labelText: 'Search requests',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRequests.isEmpty ? usersRequests.length : filteredRequests.length,
              itemBuilder: (context, index) {
                return _buildRequestItem(context, filteredRequests.isEmpty ? usersRequests[index] : filteredRequests[index]);
              },
            ),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }


  Widget _buildRequestItem(BuildContext context, String userName) {
    return GestureDetector(
      onTap: () async {
        if (rideData!['rideType'] == 'To college') {
          DateTime now = DateTime.now();

          DateTime rideDate = DateFormat('dd/MM/yyyy').parse(rideData!['reservationDeadlineDate']);

          DateTime desiredTime = DateTime(rideDate.year, rideDate.month, rideDate.day, 23, 30);

          print(rideDate);
          print(desiredTime);

          bool isBefore11_30_PM = now.isBefore(desiredTime);
          bool isBeforeRideDate = ( now.day <= rideDate.day && now.month <= rideDate.month && now.year <=rideDate.year);

          print(isBefore11_30_PM);
          print(isBeforeRideDate);

          if (isBefore11_30_PM && isBeforeRideDate || neglectTimeConstraints) {
            // Show dialog with accept/decline options
            await _showAcceptDeclineDialog(userName);
          } else if(finishRides) {

          } else {
            _showErrorNotification(context);
          }
        } else if (rideData!['rideType'] == 'Return home') {
          DateTime now = DateTime.now();

          DateTime rideDate = DateFormat('dd/MM/yyyy').parse(rideData!['reservationDeadlineDate']);

          DateTime desiredTime = DateTime(rideDate.year, rideDate.month, rideDate.day, 16, 30);

          bool isBefore4_30_PM = now.isBefore(desiredTime);
          bool isBeforeRideDate = ( now.day <= rideDate.day && now.month <= rideDate.month && now.year <=rideDate.year);

          if (isBefore4_30_PM && isBeforeRideDate || neglectTimeConstraints) {
            // Show dialog with accept/decline options
            await _showAcceptDeclineDialog(userName);
          } else {
            _showErrorNotification(context);
          }
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF1267F8),
            child: Icon(
              Icons.question_mark,
              color: Colors.white,
            ),
          ),
          title: Text(userName),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  Future<void> _showAcceptDeclineDialog(String userName) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Accept or Decline?'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _acceptRequest(userName, true); // Accept button pressed
                },
                child: Text('Accept'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _acceptRequest(userName, false); // Decline button pressed
                },
                child: Text('Decline'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _acceptRequest(String userName, bool accept) {
    String newStatus = accept ? 'Accepted' : 'Declined';
    FirebaseFirestore.instance
        .collection('requests')
        .where('rideId', isEqualTo: RideID)
        .where('userName', isEqualTo: userName)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.update({
          'status': newStatus,
        }).then((_) {
          if (newStatus == 'Accepted') {
            _showAcceptanceNotification(context);
          } else if (newStatus == 'Declined') {
            _showDeclinationNotification(context);
          }
          print('Request $newStatus successfully');
        }).catchError((error) {
          print('Error updating request status: $error');
        });
      } else {
        print('Request not found for rideId: $RideID and userName: $userName');
      }
    }).catchError((error) {
      print('Error fetching request: $error');
    });
  }

  void _showAcceptanceNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accepted Successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeclinationNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Declined Successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.purpleAccent,
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
