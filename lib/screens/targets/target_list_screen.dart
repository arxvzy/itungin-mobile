import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/target_model.dart';
import '../../providers/target_provider.dart';
import '../../widgets/app_shell.dart';
import 'add_fund_screen.dart';
import 'target_form_screen.dart';

class TargetListScreen extends StatefulWidget {
  const TargetListScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<TargetListScreen> createState() => _TargetListScreenState();
}

class _TargetListScreenState extends State<TargetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TargetProvider>().fetchTargets(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TargetProvider>();
    return Scaffold(
      bottomNavigationBar: widget.showBottomNav
          ? const AppBottomNav(currentIndex: 2)
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetchTargets,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 92),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.errorMessage != null) ...[
                      _InlineBanner(message: provider.errorMessage!),
                      const SizedBox(height: 14),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E7CF2), Color(0xFF2F9CFF)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target tabungan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pantau target, deadline, dan progress dana Anda.',
                            style: TextStyle(
                              color: Color(0xFFD9E7FF),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Saldo tersedia',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(provider.saldo),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _TargetStat(
                                  label: 'Selesai',
                                  value: provider.completedCount,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TargetStat(
                                  label: 'Berjalan',
                                  value: provider.activeCount,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TargetFormScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah target'),
                        style: FilledButton.styleFrom(
                          backgroundColor: appBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.targets.isEmpty)
                      const SoftCard(
                        child: Center(child: Text('Belum ada target.')),
                      )
                    else
                      ...provider.targets.map(
                        (target) => _TargetTile(target: target),
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

class _TargetStat extends StatelessWidget {
  const _TargetStat({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFC9D8FF),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({required this.message});

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

class _TargetTile extends StatelessWidget {
  const _TargetTile({required this.target});
  final TargetModel target;

  @override
  Widget build(BuildContext context) {
    final danger = target.progress >= 0.85;
    final color = danger ? const Color(0xFF9A2208) : appBlue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TargetFormScreen(target: target)),
        ),
        child: SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.beach_access_rounded, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.namaTarget,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          [
                            if (target.kategori.isNotEmpty) target.kategori,
                            displayDate(target.tanggalTarget),
                          ].join(' • '),
                          style: const TextStyle(color: mutedText),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(target.progress * 100).round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: target.progress,
                  minHeight: 12,
                  color: color,
                  backgroundColor: const Color(0xFFE4E6EA),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Terkumpul: ${formatRupiah(target.jumlahTerkumpul)}  Target: ${formatRupiah(target.targetJumlah)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddFundScreen(target: target),
                    ),
                  ),
                  icon: const Icon(Icons.savings_outlined),
                  label: const Text('Tambah Dana'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
