import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:project_mobile/forgot_password_screen.dart';
import 'package:project_mobile/login_screen.dart';
import 'package:project_mobile/order_history_screen.dart';
import 'package:project_mobile/payment_screen.dart';
import 'package:project_mobile/profile_screen.dart';
import 'package:project_mobile/signup_screen.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'route_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carpool App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {

        '/login': (context) => LoginScreen(),
        '/home':(context)=> HomeScreen(),
        '/forgot':(context)=> ForgotPasswordScreen(),
        '/signup':(context)=> SignUpScreen(),

        ///////////// 5od balak men screens elly fiha arguments shof hatzabatha ezay /////////////

        '/route_details':(context)=> RouteDetailsScreen('Default route'),
        '/cart':(context)=> CartScreen(bookedRoute: 'Booked route (ro7 3adel main)'),// hena 3amalen neb3at "booked route" bs 3la tol mesh ely booked fe3lan fa eb2a zabatha

        ///////////////////////////////////////////////////////////////////////////////////

        '/payment':(context)=> PaymentScreen(),
        '/profile':(context)=> ProfileScreen(),
        '/history':(context)=> OrderHistoryScreen(),
      },
      home: SplashScreen(),
    );
  }
}
