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

  Future<void> _submit() async {
    final provider = context.read<TargetProvider>();
    final ok = await provider.addFund(
      widget.target.id,
      int.tryParse(_amount.text.replaceAll('.', '')) ?? 0,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
      showSnack(context, provider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Dana')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.target.namaTarget,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Terkumpul ${formatRupiah(widget.target.jumlahTerkumpul)} dari ${formatRupiah(widget.target.targetJumlah)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah Dana'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Tambah Dana')),
        ],
      ),
    );
  }
}
