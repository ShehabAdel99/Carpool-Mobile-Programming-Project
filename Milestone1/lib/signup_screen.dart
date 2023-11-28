import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/carpool_icon.png',
              width: 125.0,
              height: 125.0,
            ),
            SizedBox(height: 10.0),
            _buildRoundedInputField('Full Name', Icons.person),
            _buildRoundedInputField('Email', Icons.email),
            _buildRoundedInputField('Phone Number', Icons.phone),
            _buildRoundedPasswordField('Password'),
            _buildRoundedPasswordField('Confirm Password'),
            SizedBox(height: 20.0),
            _buildRoundedButton('Sign Up'),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Navigate back to the LoginScreen
                Navigator.pop(context);
              },
              child: Text(
                'Back to Login',
                style: TextStyle(fontSize: 16.0),
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
      margin: EdgeInsets.symmetric(vertical: 10.0),
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

  Widget _buildRoundedPasswordField(String hintText) {
    return Container(
      width: 300.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRoundedButton(String buttonText) {
    return Container(
      width: 200.0,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          // Add logic for sign up
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF1267F8), // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
