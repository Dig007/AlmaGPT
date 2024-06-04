import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import '../database/database_helper.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final List<Message> _chatMessages = [];
  bool _isLoading = false;
  StreamSubscription<String>? _responseSubscription;

  List<Message> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage({required String userMessage}) async {
    if (_isLoading) return;

    Message userMsg = Message(content: userMessage, role: 'user');
    _chatMessages.add(userMsg);
    await DatabaseHelper.instance.insertUserMessage(userMsg);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    _chatMessages.add(Message(content: '', role: 'assistant'));
    notifyListeners();

    try {
      _responseSubscription = _chatRepository
          .sendMessageAndGetResponseStream(
        chatMessages: _chatMessages,
        onChunkReceived: (chunk) {
          _chatMessages.last = Message(
            content: _chatMessages.last.content + chunk,
            role: _chatMessages.last.role,
          );
          notifyListeners();
        },
      )
          .listen((_) {}, onDone: () {
        _isLoading = false;
        notifyListeners();
        DatabaseHelper.instance.insertMessage(_chatMessages.last);
      });
    } catch (e) {
      _chatMessages.last = Message(
        content: "Error: ${e.toString()}",
        role: _chatMessages.last.role,
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  void stopLoading() {
    _responseSubscription?.cancel();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAllMessages() async {
    _chatMessages.clear();
    await DatabaseHelper.instance.deleteAllMessages();
    notifyListeners();
  }

  Future<void> loadMessages() async {
    _chatMessages.clear();
    _chatMessages.addAll(await DatabaseHelper.instance.getMessages());
    notifyListeners();
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    super.dispose();
  }
}