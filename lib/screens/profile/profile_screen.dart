import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            auth.user?.name ?? 'User',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(auth.user?.email ?? ''),
          const SizedBox(height: 24),
          FilledButton(onPressed: auth.logout, child: const Text('Logout')),
        ],
      ),
    );
  }
}
