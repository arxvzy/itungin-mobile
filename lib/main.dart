import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/constants/api_constants.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'providers/api_diagnostics_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/target_provider.dart';
import 'providers/transaction_provider.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/dashboard_service.dart';
import 'services/target_service.dart';
import 'services/transaction_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await NotificationService.init();

  final storage = SecureStorageService();
  final diagnostics = ApiDiagnosticsProvider(ApiConstants.baseUrl);
  final dioClient = DioClient(storage, diagnostics);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: diagnostics),
        ChangeNotifierProvider(create: (_) => AppNavProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(AuthService(dioClient), storage)..checkSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardService(dioClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(TransactionService(dioClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => TargetProvider(TargetService(dioClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ChatService(dioClient)),
        ),
      ],
      child: const ItunginApp(),
    ),
  );
}
