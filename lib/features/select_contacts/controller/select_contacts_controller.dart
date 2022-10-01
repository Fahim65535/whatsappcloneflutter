import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/features/select_contacts/repo/select_contacts_repo.dart';

final getContactsProvider = FutureProvider(
  (ref) {
    final selectcontactRepo = ref.watch(selectContactRepoProvider);
    return selectcontactRepo.getContacts();
  },
);

final selectContactControllerProvider = Provider(
  (ref) {
    final selectContactrepo = ref.watch(selectContactRepoProvider);
    return SelectContactController(
        ref: ref, selectContactrepo: selectContactrepo);
  },
);

class SelectContactController {
  final ProviderRef ref;
  final SelectContactsRepo selectContactrepo;

  SelectContactController({
    required this.ref,
    required this.selectContactrepo,
  });

  void selectedContact(BuildContext context, Contact selectedContact) {
    selectContactrepo.selectcontact(context, selectedContact);
  }
}
