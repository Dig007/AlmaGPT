import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'code_snippet.dart';

Widget buildMessageBubble(BuildContext context, String content, String role) {
  List<Widget> formatContent(String content, String role) {
    List<Widget> widgets = [];

    if (role == 'assistant') {
      List<String> lines = content.split('\n');
      bool isCodeBlock = false;
      StringBuffer codeBlock = StringBuffer();
      String language = '';

      for (var line in lines) {
        if (line.trim().startsWith('```') && !isCodeBlock) {
          isCodeBlock = true;
          if (line.trim().length > 3) {
            language = line.trim().substring(3).trim();
          }
        } else if (line.trim().startsWith('```') && isCodeBlock) {
          isCodeBlock = false;
          widgets.add(
            CodeSnippet(
              code: codeBlock.toString().trim(),
              language: language,
            ),
          );
          codeBlock.clear();
        } else if (isCodeBlock) {
          codeBlock.writeln(line);
        } else {
          if (line.isNotEmpty) {
            widgets.add(MarkdownBody(
              data: line,
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
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
                code: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ));
          } else {
            widgets.add(const SizedBox(height: 8.0));
          }
        }
      }

      if (isCodeBlock && codeBlock.isNotEmpty) {
        widgets.add(
          CodeSnippet(
            code: codeBlock.toString().trim(),
            language: language,
          ),
        );
      }
    } else {
      widgets.add(Text(
        content,
        style: const TextStyle(
          fontSize: 16.0,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ));
    }

    return widgets;
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onLongPress: () {
        if (role == 'assistant') {
          showCopyDialog(context, content);
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: formatContent(content, role),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showCopyDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message));
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/copy.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Salin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}