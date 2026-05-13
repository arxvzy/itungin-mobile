import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

class ItunginApp extends StatelessWidget {
  const ItunginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itungin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0757F8),
          primary: const Color(0xFF0757F8),
          surface: const Color(0xFFF8F9FB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated
              ? const DashboardScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
