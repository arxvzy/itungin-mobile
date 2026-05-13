import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nav_provider.dart';
import '../widgets/app_shell.dart';
import 'chat/chat_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'targets/target_list_screen.dart';
import 'transactions/transaction_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final List<Widget> _pages = const [
    DashboardScreen(showBottomNav: false),
    TransactionListScreen(showBottomNav: false),
    TargetListScreen(showBottomNav: false),
    ChatScreen(showBottomNav: false),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppNavProvider>().reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNavProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          body: IndexedStack(
            index: nav.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: AppBottomNav(currentIndex: nav.currentIndex),
        );
      },
    );
  }
}
