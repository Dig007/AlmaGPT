import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class MessageInputField extends StatefulWidget {
  const MessageInputField({super.key});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isLoading = chatProvider.isLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: TextField(
                    controller: controller,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Message",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        int cursorPosition = controller.selection.baseOffset;
                        String newText = text.substring(0, 1).toUpperCase() +
                            text.substring(1);

                        if (newText != controller.text) {
                          setState(() {
                            controller.value = controller.value.copyWith(
                              text: newText,
                              selection: TextSelection.collapsed(
                                  offset: cursorPosition),
                            );
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isLoading
                ? () {
                    chatProvider.stopLoading();
                  }
                : () async {
                    if (controller.text.isNotEmpty) {
                      String userMessage = controller.text;
                      controller.clear();
                      await chatProvider.sendMessage(userMessage: userMessage);
                    }
                  },
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                isLoading ? Icons.stop : Icons.arrow_upward,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}