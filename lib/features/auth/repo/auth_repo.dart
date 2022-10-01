import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/repo/common_firebase_storage_repo.dart';
import 'package:whatsapp_fullstack/common/utils/utils.dart';
import 'package:whatsapp_fullstack/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_fullstack/features/auth/screens/user_info.dart';
import 'package:whatsapp_fullstack/models/user_model.dart';
import 'package:whatsapp_fullstack/screens/mobile_layout_screen.dart';

final authRepoProvider = Provider((ref) => AuthRepo(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ));

class AuthRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepo({
    required this.auth,
    required this.firestore,
  });

  //returning future and not void cuz we use future provider (auth controller page) instead of provider for this specific function
  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();

    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInwithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendtoken) async {
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: verificationId,
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserInfoScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void saveUserToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepoProvider)
            .storeFileToFirebase(
              'profilepic/$uid',
              profilePic,
            );
      }

      var user = UserModel(
        name: name,
        uid: uid,
        phoneNumber: auth.currentUser!.phoneNumber!,
        profilePic: photoUrl,
        isOnline: true,
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap());

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userDataId(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  void setUserstate(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update(
      {
        'isOnline': isOnline,
      },
    );
  }
}
