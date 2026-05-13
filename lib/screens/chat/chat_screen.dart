import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/target_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_shell.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  Future<void> _send([String? text]) async {
    final value = text ?? _controller.text;
    _controller.clear();
    final ok = await context.read<ChatProvider>().sendMessage(value);
    if (!mounted) return;
    if (ok) {
      context.read<DashboardProvider>().fetchDashboard();
      context.read<TransactionProvider>().fetchTransactions();
      context.read<TargetProvider>().fetchTargets();
    } else {
      final error = context.read<ChatProvider>().errorMessage;
      if (error != null) showSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    return Scaffold(
      bottomNavigationBar:
          widget.showBottomNav ? const AppBottomNav(currentIndex: 3) : null,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6F8FC), Color(0xFFEFF4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  itemCount:
                      provider.messages.length +
                      4 +
                      (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B66FF), Color(0xFF20C4FF)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: appBlue.withValues(alpha: 0.24),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'AI Financial Assistant',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Dapatkan analisis keuangan yang lebih cepat.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: mutedText),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }

                    if (index == 1) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PromptChip(
                            label: 'Analisis belanja',
                            onTap: () => _send(
                              'Tolong analisis pengeluaran saya bulan ini.',
                            ),
                          ),
                          _PromptChip(
                            label: 'Cara hemat',
                            onTap: () => _send(
                              'Bagaimana cara saya menabung lebih banyak?',
                            ),
                          ),
                          _PromptChip(
                            label: 'Tips investasi',
                            onTap: () =>
                                _send('Berikan tips investasi untuk pemula.'),
                          ),
                        ],
                      );
                    }

                    if (index == 2) {
                      return const SizedBox(height: 18);
                    }

                    final messageIndex = index - 3;
                    if (messageIndex < provider.messages.length) {
                      return _MessageBubble(
                        message: provider.messages[messageIndex],
                      );
                    }

                    if (provider.isLoading &&
                        messageIndex == provider.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (provider.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _ChatBanner(message: provider.errorMessage!),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan ke asisten AI...',
                          prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: FloatingActionButton(
                        backgroundColor: appBlue,
                        foregroundColor: Colors.white,
                        onPressed: provider.isLoading ? null : _send,
                        child: const Icon(Icons.send_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(0xFFE6E9F8),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.72,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: user
              ? const LinearGradient(
                  colors: [Color(0xFF0B66FF), Color(0xFF0F8DFF)],
                )
              : null,
          color: user ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: user
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: user ? Colors.white : textDark,
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${user ? 'ANDA' : 'AI ASSISTANT'} • ${DateFormat.Hm().format(message.createdAt)}',
                style: TextStyle(
                  color: user ? Colors.white70 : mutedText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBanner extends StatelessWidget {
  const _ChatBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD7CF)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
