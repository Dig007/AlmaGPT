import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../repositories/token_manager.dart';
import 'package:logging/logging.dart';

class ChatRepository {
  final Logger _logger = Logger('ChatRepository');

  Stream<String> sendMessageAndGetResponseStream({
    required List<Message> chatMessages,
    required Function(String) onChunkReceived,
  }) async* {
    try {
      final apiUri = Uri.parse(
          'https://genie-production-yfvxbm4e6q-uc.a.run.app/v3/completions?stream=true');

      final chatJson = chatMessages.map((message) => message.toJson()).toList();
      String token = await TokenManager.getToken();

      final request = http.Request('POST', apiUri)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..body = jsonEncode({
          "model": "OPEN_AI_CHATGPT_4_0_CHAT_MODEL",
          "parameters": {
            "temperature": 0.7,
            "topP": 1,
            "frequencyPenalty": 0,
            "presencePenalty": 0,
            "n": 1,
            "stop": []
          },
          'messages': chatJson,
        });

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        await for (var line in streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (line.contains('event: completion-done')) {
            final dataJson = line.substring(line.indexOf('{'));
            final data = jsonDecode(dataJson);
            if (data['reason'] == 'stop') {
              break;
            }
          }
          if (line.startsWith('data: ')) {
            final dataJson = line.substring(5).trim();
            final data = jsonDecode(dataJson);
            if (data.containsKey('content')) {
              onChunkReceived(data['content']);
              yield data['content'];
            }
          }
        }
      } else {
        _logger.severe('Error: ${streamedResponse.statusCode}');
        yield 'Error: ${streamedResponse.statusCode}';
      }
    } catch (e, stacktrace) {
      _logger.severe('Error: $e', e, stacktrace);
      yield 'Error: $e';
    }
  }
}