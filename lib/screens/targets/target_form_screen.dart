import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_formatter.dart';
import '../../models/target_model.dart';
import '../../providers/target_provider.dart';

class TargetFormScreen extends StatefulWidget {
  const TargetFormScreen({super.key, this.target});
  final TargetModel? target;

  @override
  State<TargetFormScreen> createState() => _TargetFormScreenState();
}

class _TargetFormScreenState extends State<TargetFormScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 90));

  @override
  void initState() {
    super.initState();
    final target = widget.target;
    if (target != null) {
      _name.text = target.namaTarget;
      _amount.text = target.targetJumlah.toString();
      _category.text = target.kategori;
      _date = DateTime.tryParse(target.tanggalTarget) ?? _date;
    }
  }

  Future<void> _save() async {
    final ok = await context.read<TargetProvider>().saveTarget(
      CreateTargetRequest(
        namaTarget: _name.text,
        targetJumlah: int.tryParse(_amount.text.replaceAll('.', '')) ?? 0,
        tanggalTarget: apiDate(_date),
        kategori: _category.text,
      ),
      id: widget.target?.id,
    );
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final id = widget.target?.id;
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus target?'),
        content: const Text('Target tabungan akan dihapus.'),
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
    await context.read<TargetProvider>().deleteTarget(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.target == null ? 'Tambah Target' : 'Edit Target'),
        actions: [
          if (widget.target != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nama Target'),
          ),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Target Jumlah'),
          ),
          TextField(
            controller: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tanggal Target'),
            subtitle: Text(apiDate(_date)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2040),
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
