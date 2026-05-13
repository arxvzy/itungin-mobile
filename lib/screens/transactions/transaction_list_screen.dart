import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_shell.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appBlue,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              provider.fetchTransactions(filter: provider.currentFilter),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 90),
            children: [
              const AppHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaksi',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kelola aliran keuangan Anda',
                      style: TextStyle(fontSize: 18, color: mutedText),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _TotalCard(
                            label: 'Total Pemasukan',
                            value: provider.totalPemasukan,
                            icon: Icons.trending_up_rounded,
                            color: appBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _TotalCard(
                      label: 'Total Pengeluaran',
                      value: provider.totalPengeluaran,
                      icon: Icons.trending_down_rounded,
                      color: const Color(0xFF9A2208),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 10,
                      children: ['semua', 'pemasukan', 'pengeluaran'].map((
                        filter,
                      ) {
                        final selected = provider.currentFilter == filter;
                        return ChoiceChip(
                          label: Text(
                            filter[0].toUpperCase() + filter.substring(1),
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              provider.fetchTransactions(filter: filter),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Daftar Transaksi',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.transactions.isEmpty)
                      const SoftCard(
                        child: Center(child: Text('Belum ada transaksi.')),
                      )
                    else
                      ...provider.transactions.map(
                        (tx) => _TransactionTile(transaction: tx),
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF505466),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatRupiah(value),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? appBlue : const Color(0xFF9A2208);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(transaction: transaction),
          ),
        ),
        child: SoftCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  transaction.isIncome
                      ? Icons.payments_outlined
                      : Icons.restaurant_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.kategori,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${displayDate(transaction.tanggal)} • ${transaction.deskripsi}',
                      style: const TextStyle(color: mutedText),
                    ),
                  ],
                ),
              ),
              Text(
                '${transaction.isIncome ? '+' : '-'} ${formatRupiah(transaction.jumlah)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
