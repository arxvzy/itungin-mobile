import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_shell.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

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
      bottomNavigationBar: widget.showBottomNav
          ? const AppBottomNav(currentIndex: 1)
          : null,
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
                          colors: [Color(0xFF0B66FF), Color(0xFF0F8DFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaksi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kelola pemasukan dan pengeluaran dalam satu tempat.',
                            style: TextStyle(
                              color: Color(0xFFD9E7FF),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Saldo sekarang',
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
                                child: _StatMiniCard(
                                  label: 'Pemasukan',
                                  value: formatRupiah(provider.totalPemasukan),
                                  icon: Icons.trending_up_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatMiniCard(
                                  label: 'Pengeluaran',
                                  value: formatRupiah(
                                    provider.totalPengeluaran,
                                  ),
                                  icon: Icons.trending_down_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['semua', 'pemasukan', 'pengeluaran'].map((
                          filter,
                        ) {
                          final selected = provider.currentFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(
                                filter[0].toUpperCase() + filter.substring(1),
                              ),
                              selected: selected,
                              onSelected: (_) =>
                                  provider.fetchTransactions(filter: filter),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Daftar transaksi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
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

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
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
                      transaction.kategori.isNotEmpty
                          ? transaction.kategori
                          : 'Tanpa kategori',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      [
                        displayDate(transaction.tanggal),
                        if (transaction.deskripsi.isNotEmpty)
                          transaction.deskripsi,
                      ].join(' • '),
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
