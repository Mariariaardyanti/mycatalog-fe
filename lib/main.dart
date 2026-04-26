import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shopping_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopping_app/features/catalog/presentation/providers/product_provider.dart';
import 'package:shopping_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/features/auth/presentation/pages/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}