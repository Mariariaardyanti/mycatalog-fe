import 'package:flutter/material.dart';

// AUTH
import 'package:shopping_app/features/auth/presentation/pages/login_page.dart';
import 'package:shopping_app/features/auth/presentation/pages/register_page.dart';
import 'package:shopping_app/features/auth/presentation/pages/verif_email_page.dart';

// CATALOG
import 'package:shopping_app/features/catalog/presentation/pages/catalog_page.dart';

class AppRouter {
  //  Route names
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const catalog = '/catalog';

  //  Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());

      case catalog:
        return MaterialPageRoute(builder: (_) => const CatalogPage());

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}