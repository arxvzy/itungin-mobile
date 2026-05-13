import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/app.dart';
import 'package:myapp/core/constants/api_constants.dart';
import 'package:myapp/core/network/dio_client.dart';
import 'package:myapp/core/storage/secure_storage_service.dart';
import 'package:myapp/providers/api_diagnostics_provider.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/providers/dashboard_provider.dart';
import 'package:myapp/providers/target_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/chat_service.dart';
import 'package:myapp/services/dashboard_service.dart';
import 'package:myapp/services/target_service.dart';
import 'package:myapp/services/transaction_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows Itungin login screen', (WidgetTester tester) async {
    final storage = SecureStorageService();
    final diagnostics = ApiDiagnosticsProvider(ApiConstants.baseUrl);
    final dioClient = DioClient(storage, diagnostics);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: diagnostics),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(AuthService(dioClient), storage),
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

    expect(find.text('Itungin'), findsWidgets);
    expect(find.text('Kelola keuangan pribadi tanpa ribet.'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}
