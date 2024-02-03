import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_db_helper.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController rideNameController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTripType;
  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController costController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate back to the home screen when the logo is pressed
            Navigator.pushReplacementNamed(context, '/home',);
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
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10.0),
                _buildRoundedInputField('Ride Name', Icons.car_crash, validator: _validateName, controller: rideNameController),
                _buildDateSelector('Ride Date : ', validator: _validateDate),
                _buildTripTypeSelector('Ride type : ', validator: _validateType),
                _buildRoundedInputField('Start location', Icons.start, validator: _validateStart, controller: startController),
                _buildRoundedInputField('Destination', Icons.read_more, validator: _validateDestination, controller: destinationController),
                _buildRoundedInputField('Ride Cost', Icons.attach_money, keyboardType: TextInputType.number, validator: _validateCost, controller: costController),
                SizedBox(height: 20.0),
                _buildRoundedButton('Add Ride'),
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
        controller: controller,
      ),
    );
  }

  Widget _buildDateSelector(String hintText, {String? Function(String?)? validator}) {
    return Container(
      width: 300.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hintText,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today),
          ),
          Text(
            selectedDate != null
                ? '${selectedDate!.toLocal().day}/${selectedDate!.toLocal().month}/${selectedDate!.toLocal().year}'
                : 'Select Date',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.blue,
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildTripTypeSelector(String hintText, {String? Function(String?)? validator}) {
    return Container(
      width: 300.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hintText,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          DropdownButton<String>(
            value: selectedTripType,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.blue),
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedTripType = newValue;
              }
              );
            },
            items: <String>['To college', 'Return home']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
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
            // Form is valid, proceed with add to Firestore logic
            _addFirestore();
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
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  // Function to handle adding to Firestore logic
  void _addFirestore() async {
    try {
      // Retrieve the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String driverId = currentUser.uid;

        // Now you can use the firebaseUserId with the getUserDetails function
        final dbHelper = DatabaseHelper();
        final userDetails = await dbHelper.getUserDetails(driverId);

        // Add logic for adding ride to Firestore
        await FirebaseFirestore.instance.collection('rides').add({
          'driverId': driverId,
          'rideName': rideNameController.text,
          'rideDate': '${selectedDate!.toLocal().day}/${selectedDate!.toLocal().month}/${selectedDate!.toLocal().year}',
          'rideType': selectedTripType!= null ? selectedTripType.toString() :'',
          'rideTime': selectedTripType.toString()== 'To college'? '7:30 am':'5:30 pm',
          'startLocation': startController.text,
          'destination': destinationController.text,
          'reservationDeadlineDate':selectedTripType.toString()== 'To college'? '${selectedDate!.toLocal().day -1}/${selectedDate!.toLocal().month}/${selectedDate!.toLocal().year}':'${selectedDate!.toLocal().day}/${selectedDate!.toLocal().month}/${selectedDate!.toLocal().year}',
          'reservationDeadlineTime':selectedTripType.toString()== 'To college'? '10:00 pm':'1:00 pm',
          'driverName': userDetails?['fullName'],
          'driverNumber': userDetails?['phoneNumber'],
          'rideCost' : '${costController.text} L.E',



          // Add other ride details here
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ride created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Handle adding to Firestore errors
      print(e);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }




  // Function to validate Name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Ride Name';
    }
    return null;
  }

  // Function to validate Date
  String? _validateDate(String? value) {
    if (selectedDate == null) {
      return 'Please choose a date';
    }
    return null;
  }

  // Function to validate Start location
  String? _validateStart(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a start location';
    }
    return null;
  }

  // Function to validate destination
  String? _validateDestination(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a destination';
    }
    return null;
  }

  // Function to validate ride type
  String? _validateType(String? value) {
    if (selectedTripType == null || selectedTripType!.isEmpty) {
      return 'Please choose a ride type';
    }
    return null;
  }

  String? _validateCost(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Ride Cost';
    }
    return null;
  }
}
