import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/enums/enums.dart';
import 'package:whatsapp_fullstack/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_fullstack/features/chat/repo/chat_repo.dart';
import 'package:whatsapp_fullstack/models/chat_contact_model.dart';
import 'package:whatsapp_fullstack/models/message_model.dart';
import 'package:whatsapp_fullstack/provider/mesage_reply_provider.dart';

final chatControllerProvider = Provider(
  (ref) {
    final chatRepo = ref.watch(chatRepoProvider);
    return ChatController(
      chatrepo: chatRepo,
      ref: ref,
    );
  },
);

class ChatController {
  final ChatRepo chatrepo;
  final ProviderRef ref;

  ChatController({
    required this.chatrepo,
    required this.ref,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return chatrepo.getChatContacts();
  }

  Stream<List<Message>> getMessages(String receiverId) {
    return chatrepo.getMessages(receiverId);
  }

  void sendtextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataProvider).whenData(
          (value) => chatrepo.sendTextMessage(
            context: context,
            text: text,
            senderUserData: value!,
            receiverUserId: receiverUserId,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(
    BuildContext context,
    String receiverUSerId,
    File file,
    MessageEnum messageEnum,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataProvider).whenData(
          (value) => chatrepo.sendFileMessage(
            context: context,
            file: file,
            receiverUserId: receiverUSerId,
            senderUserData: value!,
            ref: ref,
            messageEnum: messageEnum,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGIFmessage(
    BuildContext context,
    String gifUrl,
    String receiverUSerId,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;

    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);

    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

    ref.read(userDataProvider).whenData(
          (value) => chatrepo.sendGIFMessage(
            context: context,
            gifUrl: newgifUrl,
            senderUserData: value!,
            receiverUserId: receiverUSerId,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }
}
