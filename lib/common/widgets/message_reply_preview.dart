import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/widgets/display_text_file.dart';
import 'package:whatsapp_fullstack/provider/mesage_reply_provider.dart';

class MessageReplyPreview extends ConsumerWidget {
  const MessageReplyPreview({Key? key}) : super(key: key);

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe ? 'You' : 'Opposite',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => cancelReply(ref),
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DisplayTextandFiles(
            message: messageReply.message,
            type: messageReply.messageEnum,
          ),
        ],
      ),
    );
  }
}
