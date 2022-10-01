import 'package:whatsapp_fullstack/common/enums/enums.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String messageId;
  final String text;
  final MessageEnum type;
  final DateTime timesent;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.messageId,
    required this.text,
    required this.type,
    required this.timesent,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageId': messageId,
      'text': text,
      'type': type.type,
      'timesent': timesent.millisecondsSinceEpoch,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      messageId: map['messageId'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timesent: DateTime.fromMillisecondsSinceEpoch(map['timesent']),
      isSeen: map['isSeen'] ?? false,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }
}
