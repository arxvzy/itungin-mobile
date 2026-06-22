import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/target_model.dart';
import '../../providers/target_provider.dart';
import '../../widgets/app_shell.dart';

class AddFundScreen extends StatefulWidget {
  const AddFundScreen({super.key, required this.target});
  final TargetModel target;

  @override
  State<AddFundScreen> createState() => _AddFundScreenState();
}

class _AddFundScreenState extends State<AddFundScreen> {
  final _amount = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount =
        int.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amount <= 0) {
      setState(() {
        _localError = 'Jumlah dana harus lebih dari 0.';
      });
      return;
    }
    
    final provider = context.read<TargetProvider>();
    
    // 🔥 OPER CONTEXT AGAR SNACKBAR TEMBAH DANA MUNCUL AUTOMATIC
    final ok = await provider.addFund(context, widget.target.id, amount);
    
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
      setState(() => _localError = provider.errorMessage);
      showSnack(context, provider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Dana')),
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
                  'Tambah dana target',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.target.namaTarget,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terkumpul ${formatRupiah(widget.target.jumlahTerkumpul)} dari ${formatRupiah(widget.target.targetJumlah)}',
                  style: const TextStyle(color: Color(0xFFD9E7FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_localError != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD7CF)),
              ),
              child: Text(
                _localError!,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_localError != null) const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah Dana'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Tambah Dana'),
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