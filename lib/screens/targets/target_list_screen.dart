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
  const TargetListScreen({super.key});

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
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetchTargets,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 92),
            children: [
              const AppHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientSummaryCard(
                      label: 'Total Tabungan Target',
                      value: formatRupiah(provider.totalTarget),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _TargetStat(
                                label: 'Selesai',
                                value: provider.completedCount,
                              ),
                            ),
                            const SizedBox(width: 16),
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
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Ku',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Kelola impian finansial Anda',
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TargetFormScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah\nTarget'),
                          style: FilledButton.styleFrom(
                            backgroundColor: appBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                          '${target.kategori} • ${displayDate(target.tanggalTarget)}',
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
