import 'package:flutter/material.dart';
import 'route_details_screen.dart'; // Import the RouteDetailsScreen
import 'profile_screen.dart'; // Import the ProfileScreen
import 'cart_screen.dart'; // Import the CartScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy list of routes for demonstration purposes
  final List<String> routes = [
    "Ride to gate 3",
    "Ride to gate 3",
    "Ride to gate 4",
    "Ride from gate 3",
    "Route 5",
    "Route 6",
    "Route 7",
    "Route 8",
    "Route 9",
    "Route 10",
  ];

  TextEditingController _searchController = TextEditingController();
  List<String> filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    filteredRoutes.addAll(routes);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         // Remove the shadow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.person,
                color: Color(0xFF1267F8), // Set the color for the profile icon
              ),
              onPressed: () {
                // Navigate to the ProfileScreen
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Color(0xFF1267F8), // Set the color for the cart icon
              ),
              onPressed: () {
                // Navigate to the CartScreen  !!!!!! Don't forget the argument!!!!!!!!

                String? arg = 'DefaultRoute';
                Navigator.pushReplacementNamed(context, '/cart',arguments: arg);

              },
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent, // Set the background color to transparent
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
                filterRoutes(value);
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
      onTap: () {
        // Navigate to the RouteDetailsScreen with the selected routeName
        Navigator.pushReplacementNamed(context, '/route_details',arguments: routeName);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF1267F8), // Replace with your desired color
            child: Icon(
              Icons.location_on,
              color: Colors.white, // Replace with your desired color
            ),
          ),
          title: Text(routeName),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  void filterRoutes(String query) {
    filteredRoutes.clear();
    if (query.isEmpty) {
      filteredRoutes.addAll(routes);
    } else {
      filteredRoutes.addAll(routes
          .where((route) => route.toLowerCase().contains(query.toLowerCase())));
    }
    setState(() {});
  }
}