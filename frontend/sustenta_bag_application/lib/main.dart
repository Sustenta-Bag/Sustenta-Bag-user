import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/AppShell.dart' show AppShell;
import 'package:sustenta_bag_application/screens/ReviewScreen.dart';
import 'package:sustenta_bag_application/screens/StoreScreen.dart';
import 'screens/IntroScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/Register/RegisterStep1.dart';
import 'screens/Register/RegisterStep2.dart';
import 'screens/Register/RegisterStep3.dart';
import 'screens/bag/DeliveryOptionsScreen.dart';
import 'screens/bag/ReviewOrderScreen.dart';
import 'screens/bag/PaymentScreen.dart';
import 'screens/FavoritesScreen.dart';

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
      routes: {
        '/': (_) => const IntroScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const AppShell(),
        '/app': (_) => const AppShell(),
        '/register1': (_) => RegisterStep1(),
        '/register2': (_) => RegisterStep2(),
        '/register3': (_) => RegisterStep3(),
        '/bag/payment': (_) => const PaymentScreen(),
        '/favorites': (_) => FavoritesScreen(),
      },
      onGenerateRoute: (settings) {
        final args = (settings.arguments ?? {}) as Map<String, dynamic>;
        switch (settings.name) {
          case '/bag/deliveryOptions':
            return MaterialPageRoute(
              builder: (_) => DeliveryOptionScreen(
                hasDelivery: args['hasDelivery'] ?? false,
                userAddress: args['userAddress'] ?? '',
                storeAddress: args['storeAddress'] ?? '',
                subtotal: args['subtotal'] ?? 0.0,
              ),
            );
          case '/bag/reviewOrder':
            return MaterialPageRoute(
              builder: (_) => ReviewOrderScreen(
                subtotal: args['subtotal'] ?? 0.0,
                deliveryFee: args['deliveryFee'] ?? 0.0,
              ),
            );
          case '/review':
            return MaterialPageRoute(
              builder: (_) => ReviewScreen(
                estabelecimento: args['estabelecimento'] ?? 'Estabelecimento',
              ),
            );
          case '/store':
            return MaterialPageRoute(
              builder: (_) => StoreScreen(
                id: args['id'],
                storeName: args['storeName'],
                storeLogo: args['storeLogo'],
                storeDescription: args['storeDescription'],
                rating: args['rating'],
                workingHours: args['workingHours'],
              ),
            );

          default:
            return null;
        }
      },
    );
  }
}
