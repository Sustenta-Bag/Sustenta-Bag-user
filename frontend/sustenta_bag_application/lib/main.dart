import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sustenta_bag_application/AppShell.dart' show AppShell;
import 'package:sustenta_bag_application/screens/ReviewScreen.dart';
import 'package:sustenta_bag_application/screens/ShowReviewScreen.dart';
import 'package:sustenta_bag_application/screens/StoreScreen.dart';
import 'package:sustenta_bag_application/firebase_options.dart';
import 'package:sustenta_bag_application/screens/UserDataScreen.dart';
import 'package:sustenta_bag_application/utils/firebase_messaging_service.dart';
import 'screens/IntroScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/Register/RegisterStep1.dart';
import 'screens/Register/RegisterStep2.dart';
import 'screens/Register/RegisterStep3.dart';
import 'screens/bag/DeliveryOptionsScreen.dart';
import 'screens/bag/ReviewOrderScreen.dart';
import 'screens/bag/PaymentScreen.dart';
import 'screens/FavoritesScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  try {
    // Initialize Firebase with the correct options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Messaging
    await FirebaseMessagingService.initialize();

    // Print the FCM token for testing purposes
    final fcmToken = FirebaseMessagingService.token;
    print('FCM Token for Testing: $fcmToken');

  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue even if Firebase initialization fails
    // This ensures the app can still run without Firebase
  }

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
        '/Bag/payment': (_) => const PaymentScreen(),
        '/favorites': (_) => FavoritesScreen(),
        '/user_data': (_) => const UserDataScreen()
      },
      onGenerateRoute: (settings) {
        final args = (settings.arguments ?? {}) as Map<String, dynamic>;
        switch (settings.name) {
          case '/Bag/deliveryOptions':
            return MaterialPageRoute(
              builder: (_) => DeliveryOptionScreen(
                hasDelivery: args['hasDelivery'] ?? false,
                userAddress: args['userAddress'] ?? '',
                storeAddress: args['storeAddress'] ?? '',
                subtotal: args['subtotal'] ?? 0.0,
              ),
            );
          case '/Bag/reviewOrder':
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
                estabelecimentoId: args['estabelecimentoId'] ?? '',
              ),
            );
          case '/showReviews':
            return MaterialPageRoute(
              builder: (_) => ShowReviewScreen(
                storeId: args['storeId'] ?? '',
                storeName: args['storeName'] ?? 'Estabelecimento',
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