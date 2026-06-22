import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

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
