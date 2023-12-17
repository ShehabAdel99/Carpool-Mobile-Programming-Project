import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

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
            _buildRoundedInputField('Email', Icons.email, _emailController),
            SizedBox(height: 10.0),
            _buildRoundedPasswordField('Password', _passwordController),
            SizedBox(height: 20.0),
            _buildRoundedButton('Login'),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 16.0, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/forgot');
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedInputField(String hintText, IconData icon, TextEditingController controller) {
    return Container(
      width: 300.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: _emailError != null ? Colors.red : Colors.black),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
          errorText: _emailError,
          border: InputBorder.none,
        ),
        onChanged: (_) {
          setState(() {
            _emailError = null;
          });
        },
      ),
    );
  }

  Widget _buildRoundedPasswordField(String hintText, TextEditingController controller) {
    return Container(
      width: 300.0,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: _passwordError != null ? Colors.red : Colors.black),
      ),
      child: TextField(
        controller: controller,
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
          errorText: _passwordError,
          border: InputBorder.none,
        ),
        onChanged: (_) {
          setState(() {
            _passwordError = null;
          });
        },
      ),
    );
  }

  Widget _buildRoundedButton(String buttonText) {
    return Container(
        width: 200.0,
        height: 50.0,
        child: ElevatedButton(
        onPressed: () async {
      // Validate fields
      if (_emailController.text.isEmpty) {
        setState(() {
          _emailError = 'Email cannot be empty';
        });
      }

      if (_passwordController.text.isEmpty) {
        setState(() {
          _passwordError = 'Password cannot be empty';
        });
      }

      if (_emailError == null && _passwordError == null) {
        // Your existing login logic
        try {
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          _showSuccessNotification(context);

          // If login is successful, navigate to the home screen
          Navigator.pushReplacementNamed(context, '/home');
        } on FirebaseAuthException catch (e) {
          // Handle login errors
          _showErrorSnackbar(context, 'Invalid email or password');
        }
      }
    },
          style: ElevatedButton.styleFrom(
          primary: Color(0xFF1267F8),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          ),
          ),
          child: Text(
          buttonText,
          style: TextStyle(fontSize: 18.0,
          color: Colors.white,
          ),
          ),
          )
    );
  }

  void _showSuccessNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successful login'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

