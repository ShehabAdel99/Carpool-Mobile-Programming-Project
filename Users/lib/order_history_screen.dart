import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_mobile/HistoryDetailsScreen.dart';


class OrderHistoryScreen extends StatefulWidget {

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<String> userRoutes = [];
  List<String> userRidesNames = [];
  List<String> filteredRoutes = [];
  late String userId;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserId();
    _fetchUserRoutes();
  }

  Future<void> _getUserId() async {
    // Get the current user from FirebaseAuth
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // Set the userId using the current user's UID
        userId = user.uid;
      });
    }
  }

  Future<void> _fetchUserRoutes() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .get();
      userRoutes =
          querySnapshot.docs.map((doc) => doc['rideId'] as String).toList();

      List<Map<String, dynamic>> ridesDetailsList = [];

      for (String rideId in userRoutes) {
        Map<String, dynamic> rideDetails = await fetchRideDetails(rideId);
        if (rideDetails.isNotEmpty) {
          ridesDetailsList.add(rideDetails);
        }
      }

      for (Map<String, dynamic> rideDetails in ridesDetailsList) {
        String rideName = rideDetails['rideName'] ?? 'N/A';
        userRidesNames.add(rideName);
      }
      setState(() {
        filteredRoutes = List.from(userRidesNames);
      });
    } catch (e) {
      print('Error fetching user routes: $e');
    }
  }

  Future<Map<String, dynamic>> fetchRideDetails(String rideId) async {
    try {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();

      if (rideSnapshot.exists) {
        return rideSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching ride details: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.person,
                color: Color(0xFF1267F8),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/profile');
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


      body: Column(
        children: [
          SizedBox(height: 20.0),
          Text(
            'Your History: ',
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
                filterUserRoutes(value);
              },
              decoration: InputDecoration(
                labelText: 'Search history',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRoutes.length,
              itemBuilder: (context, index) {
                return _buildRouteItem(context, filteredRoutes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(BuildContext context, String routeName) {
    return GestureDetector(
      onTap: () async{
        String rideId = await getRideId(routeName);
        String rideStatus = await getRideStatus(rideId,userId);
        
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailsScreen(rideId: rideId, rideStatus: rideStatus),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF1267F8),
            child: Icon(
              Icons.history,
              color: Colors.white,
            ),
          ),
          title: Text(routeName),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  Future<String> getRideId(String rideName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('rideName', isEqualTo: rideName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Error fetching ride ID: $e');
    }
    return '';
  }

  Future<String> getRideStatus(String rideId, String firebaseId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('rideId', isEqualTo: rideId)
          .where('userId', isEqualTo: firebaseId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['status'] as String;
      }
    } catch (e) {
      print('Error fetching request status: $e');
    }
    return ''; // Return a default value or handle the case when the status is not found
  }



  void filterUserRoutes(String query) {
    setState(() {
      filteredRoutes = _filteredUserRoutes(query);
    });
  }

  List<String> _filteredUserRoutes(String query) {

    return userRidesNames
        .where((rideName) => rideName.toLowerCase().contains(query))
        .toList();
  }
}
