import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/utils/utils.dart';
import 'package:whatsapp_fullstack/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_fullstack/models/user_model.dart';

final selectContactRepoProvider = Provider(
    (ref) => SelectContactsRepo(firestore: FirebaseFirestore.instance));

class SelectContactsRepo {
  final FirebaseFirestore firestore;

  SelectContactsRepo({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectcontact(BuildContext context, Contact selectedContact) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;

      for (var documents in userCollection.docs) {
        var userData = UserModel.fromMap(documents.data());
        String phoneNum = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );

        if (phoneNum == userData.phoneNumber) {
          isFound = true;
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, MobileChatScreen.routeName, arguments: {
            'name': userData.name,
            'uid': userData.uid,
          });
        }

        if (!isFound) {
          showSnackBar(
              context: context,
              content: 'This contact does not exist in the App.');
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
