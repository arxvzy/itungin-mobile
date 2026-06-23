import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/forgot_provider.dart';
import '../../../widgets/app_shell.dart'; // Untuk memanggil showSnack kamu

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: Password Baru

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Prosedur Step 1: Minta OTP via Email
  Future<void> _handleRequestOtp() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _localError = 'Masukkan email Anda.');
      return;
    }
    setState(() => _localError = null);

    final provider = context.read<ForgotProvider>();
    final success = await provider.sendOtp(_emailController.text.trim());

    if (!mounted) return;
    if (success) {
      showSnack(context, 'Kode OTP berhasil dikirim ke email Anda! 📩');
      setState(() => _currentStep = 2); // Pindah ke layout OTP
    } else {
      setState(() => _localError = provider.errorMessage);
    }
  }

  // Prosedur Step 2: Verifikasi Angka OTP
  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.trim().length < 4) {
      setState(() => _localError = 'Masukkan 4 digit kode OTP dengan benar.');
      return;
    }
    setState(() => _localError = null);

    final provider = context.read<ForgotProvider>();
    final success = await provider.verifyOtp(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      showSnack(context, 'OTP Berhasil diverifikasi! Silakan ubah password.');
      setState(() => _currentStep = 3); // Pindah ke layout Password Baru
    } else {
      setState(() => _localError = provider.errorMessage);
    }
  }

  // Prosedur Step 3: Submit Password Baru ke Database
  Future<void> _handleResetPassword() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      setState(() => _localError = 'Lengkapi formulir password baru.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _localError = 'Konfirmasi password tidak cocok.');
      return;
    }
    setState(() => _localError = null);

    final provider = context.read<ForgotProvider>();
    final success = await provider.resetPassword(
      email: _emailController.text.trim(),
      otpCode: _otpController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;
    if (success) {
      showSnack(context, 'Password berhasil diperbarui! Silakan login kembali.');
      Navigator.pop(context); // Kembali ke Login Screen
    } else {
      setState(() => _localError = provider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotProvider>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentStep == 1 
                    ? 'Atur Ulang Kata Sandi' 
                    : _currentStep == 2 ? 'Verifikasi OTP' : 'Password Baru',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? 'Masukkan email terdaftar untuk menerima 4-digit kode OTP.'
                    : _currentStep == 2 
                        ? 'Masukkan kode OTP yang dikirim ke ${_emailController.text}.'
                        : 'Buatlah kata sandi baru yang kuat dan mudah diingat.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Tampilan Alert Error jika ada kendala API
              if (_localError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD7CF)),
                  ),
                  child: Text(
                    _localError!,
                    style: const TextStyle(color: Color(0xFFB42318), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // KONDISI LAYOUT DINAMIS BERDASARKAN TAHAPAN STEP
              if (_currentStep == 1) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: provider.isLoading ? null : _handleRequestOtp,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Kirim Kode OTP'),
                  ),
                ),
              ] else if (_currentStep == 2) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                  decoration: const InputDecoration(
                    labelText: 'Kode OTP 4 Digit',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: provider.isLoading ? null : _handleVerifyOtp,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verifikasi OTP'),
                  ),
                ),
              ] else if (_currentStep == 3) ...[
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: provider.isLoading ? null : _handleResetPassword,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan Password Baru'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}