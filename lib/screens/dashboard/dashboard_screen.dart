import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../providers/nav_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

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
      bottomNavigationBar:
          widget.showBottomNav ? const AppBottomNav(currentIndex: 0) : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetchDashboard,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: provider.isLoading && dashboard == null
                    ? const SizedBox(
                        height: 420,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (provider.errorMessage != null) ...[
                            _InlineBanner(
                              message: provider.errorMessage!,
                              icon: Icons.info_outline_rounded,
                              color: const Color(0xFFFFF2F0),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _HeroSummary(
                            totalWealth: dashboard?.totalWealth ?? 0,
                            monthlyIncome: dashboard?.monthlyIncome ?? 0,
                            monthlyExpense: dashboard?.monthlyExpense ?? 0,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.add_circle_outline_rounded,
                                  label: 'Transaksi',
                                  destinationIndex: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.track_changes_rounded,
                                  label: 'Target',
                                  destinationIndex: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.smart_toy_rounded,
                                  label: 'Chat AI',
                                  destinationIndex: 3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Tren bulanan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SoftCard(
                            child: SizedBox(
                              height: 260,
                              child: _DashboardChart(provider: provider),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Transaksi terbaru',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if ((dashboard?.recentTransactions ?? []).isEmpty)
                            const SoftCard(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text('Belum ada transaksi.'),
                                ),
                              ),
                            )
                          else
                            ...dashboard!.recentTransactions.map(
                              (tx) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SoftCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: tx.isIncome
                                                ? [
                                                    const Color(0xFF0B66FF),
                                                    const Color(0xFF69A4FF),
                                                  ]
                                                : [
                                                    const Color(0xFFFF7A59),
                                                    const Color(0xFFFFB199),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          tx.isIncome
                                              ? Icons.payments_rounded
                                              : Icons.shopping_bag_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.kategori,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              tx.deskripsi,
                                              style: const TextStyle(
                                                color: mutedText,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${tx.isIncome ? '+' : '-'} ${formatRupiah(tx.jumlah)}',
                                        style: TextStyle(
                                          color: tx.isIncome
                                              ? const Color(0xFF0B66FF)
                                              : const Color(0xFFB42318),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.destinationIndex,
  });
  final IconData icon;
  final String label;
  final int destinationIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.read<AppNavProvider>().setIndex(destinationIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: appBlue),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardChart extends StatelessWidget {
  const _DashboardChart({required this.provider});
  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    final chart = provider.dashboard?.chart;
    final actual = chart?.actual.isNotEmpty == true
        ? chart!.actual
        : [4.3, 5.1, 5.8, 5.4, 6.0, 6.4, 6.8];
    final target = chart?.target.isNotEmpty == true
        ? chart!.target
        : List<double>.filled(actual.length, 6.5);
    final spotsActual = List.generate(
      actual.length,
      (index) => FlSpot(index.toDouble(), actual[index]),
    );
    final spotsTarget = List.generate(
      target.length,
      (index) => FlSpot(index.toDouble(), target[index]),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: [...actual, ...target].reduce((a, b) => a > b ? a : b) + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFE9EDF4), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spotsActual,
            isCurved: true,
            color: appBlue,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  appBlue.withValues(alpha: 0.22),
                  appBlue.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: spotsTarget,
            isCurved: true,
            color: const Color(0xFF21B66F),
            barWidth: 3,
            dashArray: [8, 6],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.totalWealth,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  final int totalWealth;
  final int monthlyIncome;
  final int monthlyExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B66FF), Color(0xFF0F8DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: appBlue.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total saldo',
            style: TextStyle(
              color: Color(0xFFD9E7FF),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatRupiah(totalWealth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Pemasukan',
                  value: formatRupiah(monthlyIncome),
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  label: 'Pengeluaran',
                  value: formatRupiah(monthlyExpense),
                  icon: Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD9E7FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD7CF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFB42318)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A271A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

