import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_db_helper.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/carpool_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                _buildRoundedInputField('Full Name', Icons.person,validator: _validateName, controller: fullNameController),
                _buildRoundedInputField('Email', Icons.email, keyboardType: TextInputType.emailAddress, validator: _validateEmail, controller: emailController),
                _buildRoundedInputField('Phone Number', Icons.phone, keyboardType: TextInputType.phone,validator: _validatePhone,controller: phoneNumberController),
                _buildRoundedPasswordField('Password', controller: passwordController),
                _buildRoundedPasswordField('Confirm Password', isConfirm: true, controller: confirmPasswordController),
                SizedBox(height: 20.0),
                _buildRoundedButton('Sign Up'),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    // Navigate back to the LoginScreen
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(fontSize: 16.0, color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedInputField(String hintText, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator, required TextEditingController controller}) {
    return Container(
      width: 300.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
        validator: validator,
        controller: controller, // Provide the controller here
      ),
    );
  }

  Widget _buildRoundedPasswordField(String hintText, {bool isConfirm = false, required TextEditingController controller}) {
    return Container(
      width: 300.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: TextFormField(
        obscureText: !_isPasswordVisible,
        onChanged: (value) {
          if (!isConfirm) {
            passwordController.text = value;
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(Icons.lock),
          suffixIcon: isConfirm
              ? null
              : IconButton(
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
        validator: isConfirm ? _validateConfirmPassword : _validatePassword,
        controller: controller, // Provide the controller here
      ),
    );
  }


  Widget _buildRoundedButton(String buttonText) {
    return Container(
      width: 200.0,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            // Form is valid, proceed with signup logic
            _performSignUp();
          }
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF1267F8), // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  // Function to handle the signup logic
  void _performSignUp() async {
    try {
      // Add logic for sign up
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );


      // Save user data to SQLite database
      await DatabaseHelper().insertUser({
        'firebaseId': userCredential.user?.uid ?? '', // Use an empty string if null
        'fullName': fullNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneNumberController.text,
        'password': passwordController.text,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Show error message for email already in use
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email is already in use. Please use a different email.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Handle other authentication errors here
        print(e);
      }
    }
  }

  // Function to validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Email';
    } else if (!value.endsWith('@eng.asu.edu.eg')) {
      return 'Please enter a valid @eng.asu.edu.eg email';
    }
    return null;
  }

  // Function to validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Function to validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Password';
    } else if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Function to validate Name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Name';
    }
    return null;
  }

  // Function to validate Phone number
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Phone Number';
    } else if (value.length < 6) {
      return 'Number must be at least 10 characters';
    }
    return null;
  }
}
