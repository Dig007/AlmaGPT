import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../providers/chat_provider.dart';
import '../models/chat_model.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages();
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'images/alma.png',
              height: 25,
              width: 25,
            ),
            const SizedBox(width: 8),
            const Text(
              'AlmaGPT',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        toolbarHeight: 50,
        leadingWidth: 0,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false)
                  .deleteAllMessages();
            },
            icon: Image.asset('images/delete.png', height: 25, width: 25),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildMessageList(context),
          ),
          _MessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        // Listener untuk setiap perubahan pada konten pesan
        provider.addListener(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            }
          });
        });

        if (provider.chatMessages.isEmpty) {
          return Center(
            child: Image.asset('images/logo.png', width: 50, height: 50),
          );
        } else {
          return ListView.separated(
            controller: scrollController,
            itemCount: provider.chatMessages.length,
            padding: const EdgeInsets.only(top: 8.0, left: 10.0),
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final Message msg = provider.chatMessages[index];
              return _buildMessageBubble(context, msg.content, msg.role);
            },
          );
        }
      },
    );
  }
}

Widget _buildMessageBubble(BuildContext context, String content, String role) {
  String formattedContent = content;

  return GestureDetector(
    onLongPress: () {
      if (role == 'assistant') {
        _showCopyDialog(context, content);
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage(
                role == 'assistant' ? 'images/ai.png' : 'images/user.png',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role == 'assistant' ? "AlmaGPT" : "You",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                MarkdownBody(
                  data: formattedContent.trim(),
                  styleSheet: MarkdownStyleSheet.fromTheme(
                    ThemeData(
                      textTheme: const TextTheme(
                        bodyMedium: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ).copyWith(
                      h3: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      code: const TextStyle(
                        color: Color.fromARGB(255, 0, 255, 255),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 33, 33, 33),
                        border: Border.all(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(4, 4)),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void _showCopyDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center, // Posisikan di kanan bawah
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  'images/copy.png',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MessageInputField extends StatefulWidget {
  @override
  State<_MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<_MessageInputField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Message",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (text) {
                  // Kapitalisasi huruf pertama saat teks berubah
                  if (text.isNotEmpty) {
                    setState(() {
                      controller.value = TextEditingValue(
                        text: text.substring(0, 1).toUpperCase() +
                            text.substring(1),
                        selection: TextSelection.collapsed(offset: text.length),
                      );
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<ChatProvider>(context, listen: false)
                    .sendMessage(userMessage: controller.text);
                controller.clear();
              }
            },
            icon: Image.asset(
              'images/send.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
