import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int numberOfSeats = 1;
  String paymentType = 'Cash'; // Default payment type
  TextEditingController visaController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Seats',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (numberOfSeats > 1) {
                        numberOfSeats--;
                      }
                    });
                  },
                  child: Icon(Icons.remove),
                ),
                SizedBox(width: 10.0),
                Text('$numberOfSeats'),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numberOfSeats++;
                    });
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Payment Type',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Radio(
                  value: 'Cash',
                  groupValue: paymentType,
                  onChanged: (value) {
                    setState(() {
                      paymentType = value.toString();
                    });
                  },
                ),
                Text('Cash'),
                SizedBox(width: 20.0),
                Radio(
                  value: 'Visa',
                  groupValue: paymentType,
                  onChanged: (value) {
                    setState(() {
                      paymentType = value.toString();
                    });
                  },
                ),
                Text('Visa'),
                SizedBox(width: 20.0),
                Radio(
                  value: 'Fawry',
                  groupValue: paymentType,
                  onChanged: (value) {
                    setState(() {
                      paymentType = value.toString();
                    });
                  },
                ),
                Text('Fawry'),
              ],
            ),
            SizedBox(height: 20.0),
            // Display Visa text field if Visa is selected
            if (paymentType == 'Visa')
              _buildRoundedInputField('Visa Card Number', Icons.credit_card, visaController),
            // Display Fawry text field if Fawry is selected
            if (paymentType == 'Fawry')
              _buildRoundedInputField('Phone Number', Icons.phone, phoneController),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Add logic for completing the payment
                Navigator.pushReplacementNamed(context, '/home',);
                // Display a small notification saying "Payment Completed"
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment Completed'),
                  ),
                );
              },
              child: Text('Complete Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedInputField(String hintText, IconData icon, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
