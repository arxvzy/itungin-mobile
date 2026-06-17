import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
// TAMBAHKAN IMPORT INI
import '../services/notification_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service) {
    messages.add(
      ChatMessageModel(
        message:
            'Halo! Saya asisten AI Anda. Saya bisa membantu menganalisis pengeluaran, target tabungan, dan rencana keuangan.',
        isUser: false,
      ),
    );
  }

  final ChatService _service;
  final List<ChatMessageModel> messages = [];
  bool isLoading = false;
  String? errorMessage;

  Future<bool> sendMessage(String message) async {
    if (message.trim().isEmpty) return false;
    messages.add(ChatMessageModel(message: message.trim(), isUser: true));
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final reply = await _service.sendMessage(message.trim());
      messages.add(ChatMessageModel(message: reply, isUser: false));
      isLoading = false;
      notifyListeners();

      // 🔥 TAMBAHKAN NOTIFIKASI DI SINI:
      NotificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID Unik dari timestamp
        title: "Itungin AI Assistant 🤖",
        body: reply.length > 50 ? "${reply.substring(0, 50)}..." : reply, // Cuplikan teks AI
      );

      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'AI assistant belum dapat merespons.';
    }
    isLoading = false;
    notifyListeners();
    return false;
  }
}