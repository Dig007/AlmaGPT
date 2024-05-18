import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import '../database/database_helper.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final List<Message> _chatMessages = [];

  List<Message> get chatMessages => _chatMessages;

  Future<void> sendMessage({required String userMessage}) async {
    Message userMsg = Message(content: userMessage, role: 'user');
    _chatMessages.add(userMsg);
    await DatabaseHelper.instance.insertUserMessage(userMsg);
    notifyListeners();

    _chatMessages.add(Message(content: '', role: 'assistant'));
    try {
      await for (final _ in _chatRepository.sendMessageAndGetResponseStream(
          chatMessages: _chatMessages,
          onChunkReceived: (chunk) {
            _chatMessages.last.content += chunk;
            notifyListeners();
          })) {}
      await DatabaseHelper.instance.insertMessage(_chatMessages.last);
    } catch (e) {
      _chatMessages.last.content = "Error: ${e.toString()}";
    } finally {}
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
}
