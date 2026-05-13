import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/targets/target_list_screen.dart';
import '../screens/transactions/transaction_list_screen.dart';

const appBlue = Color(0xFF0757F8);
const textDark = Color(0xFF1B1F23);
const mutedText = Color(0xFF74788A);
const pageBg = Color(0xFFF7F8FA);

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B66FF), Color(0xFF20C4FF)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Itungin',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Personal finance companion',
                style: TextStyle(color: mutedText, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final navigator = Navigator.of(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Yakin ingin keluar dari akun ini?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB42318),
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed != true) return;
                await auth.logout();
                navigator.popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout_rounded, color: appBlue),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GradientSummaryCard extends StatelessWidget {
  const GradientSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.children = const [],
  });

  final String label;
  final String value;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF073ED9), Color(0xFF0767FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: appBlue.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFC9D8FF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (children.isNotEmpty) ...[const SizedBox(height: 24), ...children],
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.grid_view_rounded, 'Dashboard', const DashboardScreen()),
      (Icons.swap_horiz_rounded, 'Transaksi', const TransactionListScreen()),
      (Icons.track_changes_rounded, 'Target Ku', const TargetListScreen()),
      (Icons.smart_toy_rounded, 'AI Assistant', const ChatScreen()),
    ];
    return NavigationBar(
      selectedIndex: currentIndex,
      height: 74,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFEAF1FF),
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        Navigator.of(context).pushReplacement(slideRoute(items[index].$3));
      },
      destinations: [
        NavigationDestination(icon: Icon(items[0].$1), label: items[0].$2),
        NavigationDestination(icon: Icon(items[1].$1), label: items[1].$2),
        NavigationDestination(icon: Icon(items[2].$1), label: items[2].$2),
        NavigationDestination(icon: Icon(items[3].$1), label: items[3].$2),
      ],
    );
  }
}

Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
