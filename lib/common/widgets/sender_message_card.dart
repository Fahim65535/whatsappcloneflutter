import 'package:flutter/material.dart';

import 'package:whatsapp_fullstack/common/enums/enums.dart';
import 'package:whatsapp_fullstack/common/utils/color.dart';
import 'package:whatsapp_fullstack/common/widgets/display_text_file.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.onRightSwipe,
    required this.repliedtext,
    required this.username,
    required this.repliedMessagetype,
  }) : super(key: key);
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onRightSwipe;
  final String repliedtext;
  final String username;
  final MessageEnum repliedMessagetype;

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedtext.isNotEmpty;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: senderMessageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: type == MessageEnum.text
                    ? const EdgeInsets.only(
                        left: 10,
                        right: 30,
                        top: 5,
                        bottom: 20,
                      )
                    : const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 5,
                        bottom: 25,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReplying) ...[
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DisplayTextandFiles(
                          message: repliedtext,
                          type: repliedMessagetype,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    DisplayTextandFiles(
                      message: message,
                      type: type,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 2,
                right: 10,
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
