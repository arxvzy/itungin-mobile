import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_shell.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});
  final TransactionModel? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  String _type = 'pengeluaran';
  DateTime _date = DateTime.now();
  String? _localError;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type = tx.tipeTransaksi;
      _amount.text = tx.jumlah.toString();
      _category.text = tx.kategori;
      _description.text = tx.deskripsi;
      _date = DateTime.tryParse(tx.tanggal) ?? DateTime.now();
    }
  }

  Future<void> _save() async {
    final amount =
        int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (_type.isEmpty ||
        _category.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        amount <= 0) {
      setState(() {
        _localError = 'Lengkapi tipe, jumlah, kategori, dan deskripsi.';
      });
      return;
    }
    final request = CreateTransactionRequest(
      tipeTransaksi: _type,
      jumlah: amount,
      kategori: _category.text,
      deskripsi: _description.text,
      tanggal: apiDate(_date),
    );
    final provider = context.read<TransactionProvider>();
    final ok = await provider.saveTransaction(
      request,
      id: widget.transaction?.id,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
      setState(() => _localError = provider.errorMessage);
      showSnack(context, provider.errorMessage!);
    }
  }

  Future<void> _delete() async {
    final id = widget.transaction?.id;
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await context.read<TransactionProvider>().deleteTransaction(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi',
        ),
        actions: [
          if (widget.transaction != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B66FF), Color(0xFF0F8DFF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Form transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.transaction == null
                      ? 'Tambah pemasukan atau pengeluaran baru.'
                      : 'Perbarui detail transaksi yang sudah ada.',
                  style: const TextStyle(color: Color(0xFFD9E7FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _localError == null && provider.errorMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(_localError ?? provider.errorMessage),
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F0),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFD7CF)),
                    ),
                    child: Text(
                      _localError ?? provider.errorMessage ?? '',
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          if (_localError != null || provider.errorMessage != null)
            const SizedBox(height: 14),
          SoftCard(
            child: Column(
              children: [
                DropdownButtonFormField(
                  initialValue: _type,
                  items: const [
                    DropdownMenuItem(
                      value: 'pemasukan',
                      child: Text('Pemasukan'),
                    ),
                    DropdownMenuItem(
                      value: 'pengeluaran',
                      child: Text('Pengeluaran'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _type = value!),
                  decoration: const InputDecoration(
                    labelText: 'Tipe transaksi',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal'),
                  subtitle: Text(apiDate(_date)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      initialDate: _date,
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(
                      widget.transaction == null ? 'Simpan' : 'Perbarui',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
