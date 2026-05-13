import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_formatter.dart';
import '../../models/target_model.dart';
import '../../providers/target_provider.dart';
import '../../widgets/app_shell.dart';

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
  String? _localError;

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
    final amount =
        int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (_name.text.trim().isEmpty ||
        _category.text.trim().isEmpty ||
        amount <= 0) {
      setState(() {
        _localError = 'Nama target, jumlah, dan kategori wajib diisi.';
      });
      return;
    }
    final ok = await context.read<TargetProvider>().saveTarget(
      CreateTargetRequest(
        namaTarget: _name.text,
        targetJumlah: amount,
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
    final provider = context.watch<TargetProvider>();
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
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E7CF2), Color(0xFF2F9CFF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Form target',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.target == null
                      ? 'Atur tujuan tabungan baru untuk dicapai.'
                      : 'Perbarui target tabungan yang sedang berjalan.',
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
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nama Target'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Jumlah'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(widget.target == null ? 'Simpan' : 'Perbarui'),
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
