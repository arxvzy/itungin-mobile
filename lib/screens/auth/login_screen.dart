import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _localError;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() {
        _localError = 'Username dan password wajib diisi.';
      });
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_username.text, _password.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _localError = null);
      FocusScope.of(context).unfocus();
      return;
    }
    if (auth.errorMessage != null) {
      setState(() => _localError = auth.errorMessage);
      showSnack(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF4FF), Color(0xFFF7F8FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B66FF), Color(0xFF20C4FF)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Itungin',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kelola keuangan pribadi tanpa ribet.',
                  style: TextStyle(color: mutedText, fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gunakan akun Anda untuk melanjutkan.',
                        style: TextStyle(color: mutedText, fontSize: 15),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _localError == null
                            ? const SizedBox.shrink()
                            : Container(
                                width: double.infinity,
                                key: ValueKey(_localError),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2F0),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFFFD7CF),
                                  ),
                                ),
                                child: Text(
                                  _localError!,
                                  style: const TextStyle(
                                    color: Color(0xFFB42318),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                      if (_localError != null) const SizedBox(height: 16),
                      _AuthField(
                        label: 'Username',
                        controller: _username,
                        icon: Icons.person_outline,
                        hint: 'budi',
                      ),
                      const SizedBox(height: 18),
                      _AuthField(
                        label: 'Password',
                        controller: _password,
                        icon: Icons.lock_outline,
                        hint: 'password',
                        obscureText: _obscure,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: appBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(color: mutedText),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: const Text('Daftar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF505466),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
