import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'requests_screen.dart';


class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> driverRoutes = [];
  List<String> filteredRoutes = [];
  late String driverId;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDriverId();
    _fetchDriverRoutes();
  }

  Future<void> _getDriverId() async {
    // Get the current user from FirebaseAuth
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // Set the driverId using the current user's UID
        driverId = user.uid;
      });
    }
  }

  Future<void> _fetchDriverRoutes() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('driverId', isEqualTo: driverId)
          .get();

      setState(() {
        driverRoutes =
            querySnapshot.docs.map((doc) => doc['rideName'] as String).toList();
        filteredRoutes = List.from(driverRoutes);
      });
    } catch (e) {
      print('Error fetching driver routes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            IconButton(
              icon: Icon(
                Icons.add_location_alt_outlined,
                color: Color(0xFF1267F8),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/add');
              },
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/carpool_icon.png',
              width: 125.0,
              height: 125.0,
            ),
          ),
          Text(
            'Your Trips: ',
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
                filterDriverRoutes(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Routes',
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RequestsScreen(rideId: rideId),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF1267F8),
            child: Icon(
              Icons.location_on,
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
  void filterDriverRoutes(String query) {
    setState(() {
      filteredRoutes = _filteredDriverRoutes(query);
    });
  }

  List<String> _filteredDriverRoutes(String query) {
    return driverRoutes
        .where((route) => route.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
