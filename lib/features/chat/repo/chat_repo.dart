import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_fullstack/common/enums/enums.dart';
import 'package:whatsapp_fullstack/common/repo/common_firebase_storage_repo.dart';
import 'package:whatsapp_fullstack/common/utils/utils.dart';
import 'package:whatsapp_fullstack/models/chat_contact_model.dart';
import 'package:whatsapp_fullstack/models/message_model.dart';
import 'package:whatsapp_fullstack/models/user_model.dart';
import 'package:whatsapp_fullstack/provider/mesage_reply_provider.dart';

final chatRepoProvider = Provider(
  (ref) => ChatRepo(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepo({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap(
      (event) async {
        List<ChatContact> contacts = [];
        for (var documents in event.docs) {
          var chatContact = ChatContact.fromMap(documents.data());
          var userData = await firestore
              .collection('users')
              .doc(chatContact.contactId)
              .get();
          var user = UserModel.fromMap(userData.data()!);

          contacts.add(
            ChatContact(
                name: user.name,
                profilePic: user.profilePic,
                timesent: chatContact.timesent,
                contactId: chatContact.contactId,
                lastMsg: chatContact.lastMsg),
          );
        }
        return contacts;
      },
    );
  }

  Stream<List<Message>> getMessages(String receiverId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('timesent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var document in event.docs) {
          messages.add(
            Message.fromMap(document.data()),
          );
        }
        return messages;
      },
    );
  }

  //Private function used in sendtextmessage function
  void _saveDataToContactsSubCollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timesent,
    String receiverUserId,
  ) async {
    // users -> receiverId -> chats -> senderId -> setData (for receiver)
    var receiverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      timesent: timesent,
      contactId: auth.currentUser!.uid,
      lastMsg: text,
    );

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          receiverChatContact.toMap(),
        );

    // users -> senderId -> chats -> receiverId -> setData (for current user)
    var senderChatContact = ChatContact(
      name: receiverUserData!.name,
      profilePic: receiverUserData.profilePic,
      timesent: timesent,
      contactId: receiverUserData.uid,
      lastMsg: text,
    );

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubCollection({
    required String receiverUsedId,
    required String text,
    required DateTime timesent,
    required String messageId,
    required MessageEnum messageType,
    required String userName,
    required String receiverUsername,
    required String senderUsername,
    required MessageReply? messageReply,
  }) async {
    var message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUsedId,
      messageId: messageId,
      text: text,
      type: messageType,
      timesent: timesent,
      isSeen: false,
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : receiverUsername,
    );

    // users -> sender id -> chats -> reciever id -> messages -> message id -> store message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUsedId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );

    // users -> reciever id -> chats -> sender id -> messages -> message id -> store message
    await firestore
        .collection('users')
        .doc(receiverUsedId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }

// sendTextMessage function
  void sendTextMessage({
    required BuildContext context,
    required String text,
    required UserModel senderUserData,
    required String receiverUserId,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userData =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userData.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactsSubCollection(
        senderUserData,
        receiverUserData,
        text,
        timeSent,
        receiverUserId,
      );

      _saveMessageToMessageSubCollection(
        receiverUsedId: receiverUserId,
        text: text,
        timesent: timeSent,
        messageId: messageId,
        userName: senderUserData.name,
        receiverUsername: receiverUserData.name,
        senderUsername: senderUserData.name,
        messageType: MessageEnum.text,
        messageReply: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timesent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl =
          await ref.read(commonFirebaseStorageRepoProvider).storeFileToFirebase(
                'chats/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
                file,
              );

      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubCollection(
        senderUserData,
        receiverUserData,
        contactMsg,
        timesent,
        receiverUserId,
      );

      _saveMessageToMessageSubCollection(
        receiverUsedId: receiverUserId,
        text: imageUrl,
        timesent: timesent,
        messageId: messageId,
        messageType: messageEnum,
        userName: senderUserData.name,
        receiverUsername: receiverUserData.name,
        senderUsername: senderUserData.name,
        messageReply: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required UserModel senderUserData,
    required String receiverUserId,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userData =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userData.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactsSubCollection(
        senderUserData,
        receiverUserData,
        'GIF',
        timeSent,
        receiverUserId,
      );

      _saveMessageToMessageSubCollection(
        receiverUsedId: receiverUserId,
        text: gifUrl,
        timesent: timeSent,
        messageId: messageId,
        userName: senderUserData.name,
        receiverUsername: receiverUserData.name,
        senderUsername: senderUserData.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
