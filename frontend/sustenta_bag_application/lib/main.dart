import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/screens/FavoritesScreen.dart';
import 'package:sustenta_bag_application/screens/Register/RegisterStep1.dart';
import 'package:sustenta_bag_application/screens/Register/RegisterStep2.dart';
import 'package:sustenta_bag_application/screens/Register/RegisterStep3.dart';
import 'package:sustenta_bag_application/screens/profileScreen.dart';
import 'screens/IntroScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/bag/BagScreen.dart';
import 'screens/bag/DeliveryOptionsScreen.dart';
import 'screens/bag/ReviewOrderScreen.dart';
import 'screens/bag/PaymentScreen.dart'; 
import 'screens/history/HistoryScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SustentaBag',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const IntroScreen());

          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());

          case '/home':
            return MaterialPageRoute(
                builder: (context) => const DashboardScreen());

          case '/bag':
            return MaterialPageRoute(builder: (context) => const BagScreen());

          case '/bag/deliveryOptions':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => DeliveryOptionScreen(
                hasDelivery: args['hasDelivery'] ?? false,
                userAddress: args['userAddress'] ?? '',
                storeAddress: args['storeAddress'] ?? '',
                subtotal: args['subtotal'] ?? 0.0, 
              ),
            );

          case '/bag/reviewOrder':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => ReviewOrderScreen(
                subtotal: args['subtotal'] ?? 0.0,
                deliveryFee: args['deliveryFee'] ?? 0.0,
              ),
            );
          case '/bag/payment':
            return MaterialPageRoute(
                builder: (context) => const PaymentScreen());
          case '/history':
            return MaterialPageRoute(
                builder: (context) => const HistoryScreen());
          case '/register1':
            return MaterialPageRoute(builder: (context) => RegisterStep1());

          case '/register2':
            return MaterialPageRoute(builder: (context) => RegisterStep2());

          case '/register3':
            return MaterialPageRoute(builder: (context) => RegisterStep3());

          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfileScreen());

          case '/favorites':
            return MaterialPageRoute(builder: (context) => FavoritesScreen());

          default:
            return MaterialPageRoute(builder: (context) => const IntroScreen());
        }
      },
    );
  }
}
