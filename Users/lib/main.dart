import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'local_db_helper.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final database = await DatabaseHelper().database;

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MyApp(database: database),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Database database;

  MyApp({required this.database});

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
        '/signup':(context)=> SignUpScreen(),



        '/payment':(context)=> PaymentScreen(),
        '/profile':(context)=> ProfileScreen(),
        '/history':(context)=> OrderHistoryScreen(),
      },
      home: SplashScreen(),
    );
  }
}
