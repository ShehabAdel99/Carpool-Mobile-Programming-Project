import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'route_details_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> allRides = [];
  List<String> filteredRoutes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .get();

      setState(() {
        allRides.addAll(querySnapshot.docs.map((doc) => doc['rideName'] as String));
        filteredRoutes = List.from(allRides);
      });
    } catch (e) {
      print('Error fetching rides: $e');
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
                Icons.shopping_cart,
                color: Color(0xFF1267F8),
              ),
              onPressed: () {
                String? arg = 'DefaultRoute';
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(bookedRoute: arg),
                  ),
                );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                filterRides(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Rides',
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
      onTap: () async {
        String rideId = await getRideId(routeName);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailsScreen(rideId: rideId),
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

  void filterRides(String query) {
    setState(() {
      filteredRoutes = _filteredRides(query);
    });
  }

  List<String> _filteredRides(String query) {
    return allRides
        .where((ride) => ride.toLowerCase().contains(query.toLowerCase()))
        .toList();
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
}
