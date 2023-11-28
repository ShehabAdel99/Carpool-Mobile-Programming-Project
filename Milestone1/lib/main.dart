import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:project_mobile/login_screen.dart';
import 'splash_screen.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'route_details_screen.dart';

void main() {
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
      },
      home: SplashScreen(),
    );
  }
}
