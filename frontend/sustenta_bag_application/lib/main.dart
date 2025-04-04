import 'package:flutter/material.dart';
import 'screens/IntroScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/sacola/BagScreen.dart';
import 'screens/sacola/DeliveryOptionsScreen.dart';

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
              ),
            );
          default:
            return MaterialPageRoute(builder: (context) => const IntroScreen());
        }
      },
    );
  }
}
