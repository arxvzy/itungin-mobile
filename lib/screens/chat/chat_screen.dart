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
  const ChatScreen({super.key});

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
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  const SizedBox(height: 22),
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: appBlue,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: appBlue.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'AI Financial Assistant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'How can I help your finances today?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: mutedText),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _PromptChip(
                        label: 'Analyze my spending',
                        onTap: () => _send(
                          'Tolong analisis pengeluaran saya bulan ini.',
                        ),
                      ),
                      _PromptChip(
                        label: 'How to save more?',
                        onTap: () =>
                            _send('Bagaimana cara saya menabung lebih banyak?'),
                      ),
                      _PromptChip(
                        label: 'Investment tips',
                        onTap: () =>
                            _send('Berikan tips investasi untuk pemula.'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ...provider.messages.map(
                    (message) => _MessageBubble(message: message),
                  ),
                  if (provider.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 10, 28, 18),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        prefixIcon: const Icon(Icons.attach_file_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    backgroundColor: appBlue,
                    foregroundColor: Colors.white,
                    onPressed: provider.isLoading ? null : _send,
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: user ? appBlue : Colors.white,
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
                fontSize: 18,
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
