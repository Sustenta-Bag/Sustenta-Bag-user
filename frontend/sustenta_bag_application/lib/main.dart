import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sustenta_bag_application/screens/app_shell.dart' show AppShell;
import 'package:sustenta_bag_application/screens/Edit/edit_step1.dart';
import 'package:sustenta_bag_application/screens/Edit/edit_step2.dart';
import 'package:sustenta_bag_application/screens/Review/show_review_screen.dart';
import 'package:sustenta_bag_application/screens/business/business_screen.dart';
import 'package:sustenta_bag_application/screens/register/register_address_screen.dart';
import 'package:sustenta_bag_application/screens/register/register_personal_screen.dart';
import 'package:sustenta_bag_application/firebase_options.dart';
import 'package:sustenta_bag_application/screens/user_data_screen.dart';
import 'package:sustenta_bag_application/services/firebase_messaging_service.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/bag/delivery_options_screen.dart';
import 'screens/bag/review_order_screen.dart';
import 'screens/bag/payment_screen.dart';
import 'screens/bag/pending_order_details_screen.dart';
import 'screens/favorites_screen.dart';
import 'models/order.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseMessagingService.initialize();

    final fcmToken = FirebaseMessagingService.token;
    print('FCM Token for Testing: $fcmToken');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SustentaBag',
      navigatorObservers: [routeObserver],
      initialRoute: '/',
      routes: {
        '/': (_) => const IntroScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const AppShell(),
        '/app': (_) => const AppShell(),
        '/register-personal': (_) => RegisterPersonalScreen(),
        '/register-address': (_) => RegisterAddressScreen(),
        '/bag/payment': (_) => const PaymentScreen(),
        '/favorites': (_) => FavoritesScreen(),
        '/user_data': (_) => const UserDataScreen(),
        "/edit_step1": (ctx) => const EditUserStep1(),
        '/edit_step2': (ctx) => const EditUserStep2(),
      },
      onGenerateRoute: (settings) {
        final args = (settings.arguments ?? {}) as Map<String, dynamic>;
        switch (settings.name) {
          case '/bag/deliveryOptions':
            return MaterialPageRoute(
              builder: (_) => DeliveryOptionScreen(
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
                business: args['business'] ?? {},
              ),
            );
          case '/bag/pendingOrderDetails':
            return MaterialPageRoute(
              builder: (_) => PendingOrderDetailsScreen(
                order: args['order'] as Order,
              ),
            );

          default:
            return null;
        }
      },
    );
  }
}
