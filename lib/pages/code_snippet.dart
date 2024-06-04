import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import '../themes/theme.dart';

class CodeSnippet extends StatelessWidget {
  final String code;
  final String language;

  const CodeSnippet({super.key, required this.code, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 35.0,
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.toUpperCase(),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Image.asset('images/copy.png', height: 16, width: 16),
                          const SizedBox(width: 4.0),
                          const Text(
                            'Salin Kode',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color.fromARGB(255, 0, 0, 0),
            child: HighlightView(
              code,
              language: language,
              theme: uwuTheme,
              textStyle: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
