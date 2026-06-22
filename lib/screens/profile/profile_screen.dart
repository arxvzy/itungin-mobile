import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 

import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/app_shell.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB42318),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Kartu Profil User
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B66FF), Color(0xFF0F8DFF)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded, color: appBlue),
                ),
                const SizedBox(height: 16),
                Text(
                  auth.user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${auth.user?.username ?? '-'}',
                  style: const TextStyle(color: Color(0xFFD9E7FF)),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.user?.email ?? '',
                  style: const TextStyle(color: Color(0xFFD9E7FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          
          // 2. Kartu Saldo Saat Ini
          SoftCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: appBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo saat ini',
                        style: TextStyle(
                          color: mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah(auth.user?.saldo ?? 0),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. MENU FITUR PENGINGAT NOTIFIKASI (DENGAN PEMICU IZIN PAKSA)
          SoftCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFFD95D00),
                ),
              ),
              title: const Text(
                "Pengingat Keuangan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text("Atur jam pengingat catat keuangan"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: mutedText),
              onTap: () async {
                // 🌟 LANGKAH EMERGENSI: Paksa Android memunculkan pop-up izin di detik tombol ini diklik
                final androidPlugin = FlutterLocalNotificationsPlugin()
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
                if (androidPlugin != null) {
                  await androidPlugin.requestNotificationsPermission();
                  await androidPlugin.requestExactAlarmsPermission();
                }

                // 1. Munculkan dialog pemilihan jam digital
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  // 2. Daftarkan alarm harian di background
                  await NotificationService.scheduleDailyNotification(
                    id: 888,
                    title: "💸 Catat Keuangan Yuk! 💸",
                    body: "Sudah belanja apa saja hari ini? Jangan lupa rapikan catatannya di Itungin ya!",
                    hour: pickedTime.hour,
                    minute: pickedTime.minute,
                  );

                  // 3. Tembakkan banner konfirmasi instan lokal HP
                  await NotificationService.showInstantNotification(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: "✅ Pengingat Berhasil Diaktifkan! ",
                    body: "Itungin akan mengingatkanmu setiap hari jam ${pickedTime.format(context)}.",
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 18),

          // 4. Tombol Logout
          FilledButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}