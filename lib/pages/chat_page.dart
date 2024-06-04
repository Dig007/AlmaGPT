import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import 'message_bubble.dart';
import 'message_input_field.dart';

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
              'images/ai.png',
              height: 25,
              width: 25,
            ),
            const SizedBox(width: 8),
            const Text(
              'AlmaGPT',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
          const MessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
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
            child: Image.asset('images/ai.png', width: 40, height: 40),
          );
        } else {
          return ListView.separated(
            controller: scrollController,
            itemCount: provider.chatMessages.length,
            padding: const EdgeInsets.only(top: 8.0, left: 10.0),
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final Message msg = provider.chatMessages[index];
              return buildMessageBubble(context, msg.content, msg.role);
            },
          );
        }
      },
    );
  }
}