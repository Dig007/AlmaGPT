import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  final List<Choice> choices;

  ChatModel({
    required this.choices,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        choices: List<Choice>.from(json["choices"].map((x) => Choice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "choices": List<dynamic>.from(choices.map((x) => x.toJson())),
      };
}

class Choice {
  final Message message;
  final String finishReason;

  Choice({
    required this.message,
    required this.finishReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        message: Message.fromJson(json["message"]),
        finishReason: json["finish_reason"],
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
        "finish_reason": finishReason,
      };
}

class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        role: json["role"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "role": role,
        "content": content,
      };
}