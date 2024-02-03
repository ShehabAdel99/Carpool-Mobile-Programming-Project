import 'package:flutter/material.dart';
import 'order_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'local_db_helper.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDataFromDatabase(), // Fetch user data from SQLite
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching data
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Show an error message if data fetching fails
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          // Show a default UI if no data is available
          return Center(child: Text('No user data available'));
        } else {
          // Data fetching successful, build the UI with user data
          final userData = snapshot.data!;
          return _buildProfileScreen(context, userData);
        }
      },
    );
  }

  Future<Map<String, dynamic>> _getUserDataFromDatabase() async {
    try {
      // Get the currently logged-in user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      // Return an empty map if no user is logged in
      if (currentUser == null) {
        return {};
      }

      // Query the database for user data based on Firebase ID
      final database = await DatabaseHelper().database;
      final List<Map<String, dynamic>> result = await database.query(
        'users',
        where: 'firebaseId = ?',
        whereArgs: [currentUser.uid],
        limit: 1,
      );

      // Return the user data if found, otherwise an empty map
      return result.isNotEmpty ? result.first : {};
    } catch (e) {
      print('Error getting user data from database: $e');
      return {};
    }
  }

  Widget _buildProfileScreen(BuildContext context, Map<String, dynamic> userData) {
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
        actions: [
          // Add a logout icon
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF1267F8)),
            onPressed: () async {
              try {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();

                _showSuccessNotification(context);

                // Navigate back to the login screen
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print("Error signing out: $e");
                // Handle any errors during sign out
              }
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16.0),
          CircleAvatar(
            radius: 80.0,
            backgroundImage: AssetImage('assets/images/profile_picture.png'),
          ),
          SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Username:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['fullName'] ?? 'N/A',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Email:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['email'] ?? 'N/A',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Phone Number:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['phoneNumber'] ?? 'N/A',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    // Add more user details as needed
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to the OrderHistoryScreen
                  Navigator.pushReplacementNamed(context, '/history');
                },
                child: Text('Order History'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _showSuccessNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successful logout'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
