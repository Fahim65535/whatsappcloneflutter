class UserModel {
  final String name;
  final String uid;
  final String phoneNumber;
  final String profilePic;
  final bool isOnline;
  final List<String> groupId;
  UserModel({
    required this.name,
    required this.uid,
    required this.phoneNumber,
    required this.profilePic,
    required this.isOnline,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'groupId': groupId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      groupId: List<String>.from(map['groupId']),
    );
  }
}
