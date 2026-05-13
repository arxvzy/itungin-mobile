import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final dashboard = provider.dashboard;
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetchDashboard,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const AppHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: provider.isLoading && dashboard == null
                    ? const SizedBox(
                        height: 420,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientSummaryCard(
                            label: 'Total Saldo',
                            value: formatRupiah(dashboard?.totalWealth ?? 0),
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Text(
                                  '+12.5% than last month',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _Shortcut(
                                icon: Icons.send_rounded,
                                label: 'Kirim',
                              ),
                              _Shortcut(
                                icon: Icons.add_circle_outline_rounded,
                                label: 'Top Up',
                              ),
                              _Shortcut(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Tagihan',
                              ),
                              _Shortcut(
                                icon: Icons.more_horiz_rounded,
                                label: 'Lainnya',
                              ),
                            ],
                          ),
                          const SizedBox(height: 34),
                          Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'Spending Curve',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                'Last 7 Days',
                                style: TextStyle(
                                  color: appBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SoftCard(
                            child: SizedBox(
                              height: 220,
                              child: _DashboardChart(provider: provider),
                            ),
                          ),
                          const SizedBox(height: 34),
                          const Text(
                            'Recent Activities',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if ((dashboard?.recentTransactions ?? []).isEmpty)
                            const SoftCard(
                              child: Center(
                                child: Text('Belum ada transaksi.'),
                              ),
                            )
                          else
                            ...dashboard!.recentTransactions.map(
                              (tx) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: SoftCard(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECEFFE),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: Icon(
                                          tx.isIncome
                                              ? Icons.payments_outlined
                                              : Icons.restaurant_rounded,
                                          color: appBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.kategori,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              tx.deskripsi,
                                              style: const TextStyle(
                                                color: mutedText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${tx.isIncome ? '+' : '-'} ${formatRupiah(tx.jumlah)}',
                                        style: TextStyle(
                                          color: tx.isIncome
                                              ? appBlue
                                              : const Color(0xFF9A2208),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E7E9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: appBlue, size: 30),
        ),
        const SizedBox(height: 10),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF666A73),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DashboardChart extends StatelessWidget {
  const _DashboardChart({required this.provider});
  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    final actual = provider.dashboard?.chart.actual;
    final values = actual == null || actual.isEmpty
        ? [3.0, 5.0, 6.0, 2.2, 7.0, 3.5, 5.0]
        : actual;
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                width: 28,
                color: index == 2 ? appBlue : const Color(0xFF91A7FF),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
