import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 22),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8ECF5),
            child: Icon(Icons.person, color: Colors.blueGrey.shade700),
          ),
          const SizedBox(width: 16),
          const Text(
            'Itungin',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: appBlue,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications_none_rounded,
            color: appBlue,
            size: 32,
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final selected = index == currentIndex;
          final item = items[index];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: selected
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => item.$3),
                    ),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFEAF1FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.$1,
                      color: selected ? appBlue : const Color(0xFF9AA8BC),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.$2.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? appBlue : const Color(0xFF9AA8BC),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
