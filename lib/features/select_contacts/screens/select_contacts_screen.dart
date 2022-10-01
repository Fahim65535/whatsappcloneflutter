import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/widgets/error.dart';
import 'package:whatsapp_fullstack/common/widgets/loader.dart';
import 'package:whatsapp_fullstack/features/select_contacts/controller/select_contacts_controller.dart';

class SelectContactScreen extends ConsumerWidget {
  static const routeName = '/select-contact';
  const SelectContactScreen({Key? key}) : super(key: key);

  void selectContact(
      WidgetRef ref, BuildContext context, Contact selectedContact) {
    ref
        .read(selectContactControllerProvider)
        .selectedContact(context, selectedContact);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contact"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
            data: (contactList) => ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];
                return InkWell(
                  onTap: () => selectContact(ref, context, contact),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(fontSize: 18),
                      ),
                      leading: contact.photo == null
                          ? null
                          : CircleAvatar(
                              backgroundImage: MemoryImage(contact.photo!),
                              radius: 35,
                            ),
                    ),
                  ),
                );
              },
            ),
            error: (err, trace) => ErrorScreen(
              text: (err.toString()),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
