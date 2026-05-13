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
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: ClipRect(
                    child: Stack(
                      children: List.generate(_pages.length, (index) {
                        final isCurrent = index == nav.currentIndex;
                        final targetOffset = isCurrent
                            ? Offset.zero
                            : Offset(index < nav.currentIndex ? -1.0 : 1.0, 0);
                        return Positioned.fill(
                          child: IgnorePointer(
                            ignoring: !isCurrent,
                            child: AnimatedSlide(
                              offset: targetOffset,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              child: AnimatedOpacity(
                                opacity: isCurrent ? 1 : 0,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                                child: _pages[index],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNav(currentIndex: nav.currentIndex),
        );
      },
    );
  }
}
