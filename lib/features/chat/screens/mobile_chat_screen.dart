import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_fullstack/common/utils/color.dart';
import 'package:whatsapp_fullstack/common/widgets/chat_List.dart';
import 'package:whatsapp_fullstack/common/widgets/loader.dart';
import 'package:whatsapp_fullstack/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_fullstack/features/chat/widgets/bottom_field_chat.dart';
import 'package:whatsapp_fullstack/models/user_model.dart';

class MobileChatScreen extends ConsumerWidget {
  static const routeName = '/chat-screen';
  final String name;
  final String uid;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<UserModel>(
            stream: ref.read(authcontrollerProvider).userDataId(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  Text(
                    snapshot.data!.isOnline ? 'online' : 'offline',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 13),
                  ),
                ],
              );
            }),
        centerTitle: false,
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(receiverUserId: uid),
          ),
          BottomFieldChat(
            receiverUserId: uid,
          ),
        ],
      ),
    );
  }
}
