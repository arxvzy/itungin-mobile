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
    final request = CreateTransactionRequest(
      tipeTransaksi: _type,
      jumlah: int.tryParse(_amount.text.replaceAll('.', '')) ?? 0,
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
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField(
            initialValue: _type,
            items: const [
              DropdownMenuItem(value: 'pemasukan', child: Text('Pemasukan')),
              DropdownMenuItem(
                value: 'pengeluaran',
                child: Text('Pengeluaran'),
              ),
            ],
            onChanged: (value) => setState(() => _type = value!),
            decoration: const InputDecoration(labelText: 'Tipe Transaksi'),
          ),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah'),
          ),
          TextField(
            controller: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Deskripsi'),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Simpan')),
        ],
      ),
    );
  }
}
