import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_fullstack/common/widgets/loader.dart';
import 'package:whatsapp_fullstack/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_fullstack/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_fullstack/models/chat_contact_model.dart';

class ContactList extends ConsumerWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: StreamBuilder<List<ChatContact>>(
          stream: ref.watch(chatControllerProvider).getChatContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var chatContactData = snapshot.data![index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, MobileChatScreen.routeName,
                          arguments: {
                            'name': chatContactData.name,
                            'uid': chatContactData.contactId,
                          }),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            chatContactData.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              chatContactData.lastMsg,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(chatContactData.profilePic),
                            radius: 30,
                          ),
                          trailing: Text(
                            DateFormat.Hm().format(chatContactData.timesent),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
    );
  }
}
