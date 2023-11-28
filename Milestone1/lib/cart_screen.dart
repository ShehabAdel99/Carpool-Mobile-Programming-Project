import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_screen.dart';

class CartProvider extends ChangeNotifier {
  List<String> _bookedRoutes = [];

  List<String> get bookedRoutes => _bookedRoutes;

  void addBookedRoute(String route) {
    if (route != "DefaultRoute" && !_bookedRoutes.contains(route)) {
      _bookedRoutes.add(route);
      notifyListeners();
    }
  }

  void removeBookedRoute(String route) {
    _bookedRoutes.remove(route);
    notifyListeners();
  }
}

class CartScreen extends StatelessWidget {
  final String bookedRoute;

  CartScreen({required this.bookedRoute});

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context);

    // Add the booked route to the list when the CartScreen is opened
    cartProvider.addBookedRoute(bookedRoute);

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
              'Booked Routes',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            // Display a message if no routes are booked
            if (cartProvider.bookedRoutes.isEmpty)
              Text("No booked routes yet"),
            // Display the booked routes if there are any
            if (cartProvider.bookedRoutes.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.bookedRoutes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(cartProvider.bookedRoutes[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Remove the route when the delete icon is pressed
                            cartProvider.removeBookedRoute(
                                cartProvider.bookedRoutes[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.0),
            Visibility(
              visible: cartProvider.bookedRoutes.isNotEmpty,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the PaymentScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentScreen()),
                  );
                },
                child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
