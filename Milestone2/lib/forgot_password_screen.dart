import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            Image.asset(
              'assets/images/carpool_icon.png',
              width: 125.0,
              height: 125.0,
            ),
            SizedBox(height: 30.0),
            Text(
              'Recover Password',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,

              ),
            ),
            SizedBox(height: 20.0),
            _buildRoundedInputField('Email', Icons.email),
            SizedBox(height: 20.0),
            _buildRoundedButton('Send Password via Email'),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Navigate back to the LoginScreen
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 16.0,color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedInputField(String hintText, IconData icon) {
    return Container(
      width: 300.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRoundedButton(String buttonText) {
    return Container(
      width: 250.0,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          // Add logic for sending password via email
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF1267F8), // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 16.0,color: Colors.white),
        ),
      ),
    );
  }
}
