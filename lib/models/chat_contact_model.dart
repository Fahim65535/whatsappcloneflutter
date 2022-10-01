class ChatContact {
  final String name;
  final String profilePic;
  final DateTime timesent;
  final String contactId;
  final String lastMsg;

  ChatContact({
    required this.name,
    required this.profilePic,
    required this.timesent,
    required this.contactId,
    required this.lastMsg,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'timesent': timesent.millisecondsSinceEpoch,
      'contactId': contactId,
      'lastMsg': lastMsg,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      timesent: DateTime.fromMillisecondsSinceEpoch(map['timesent']),
      contactId: map['contactId'] ?? '',
      lastMsg: map['lastMsg'] ?? '',
    );
  }
}
