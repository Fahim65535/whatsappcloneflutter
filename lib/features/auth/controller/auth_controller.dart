import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_fullstack/features/auth/repo/auth_repo.dart';
import 'package:whatsapp_fullstack/models/user_model.dart';

final authcontrollerProvider = Provider(
  (ref) {
    final authRepo = ref.watch(authRepoProvider);
    return AuthController(authRepo: authRepo, ref: ref);
  },
);

final userDataProvider = FutureProvider(
  (ref) {
    final authcontroller = ref.watch(authcontrollerProvider);
    return authcontroller.getCurrentUserData();
  },
);

class AuthController {
  final AuthRepo authRepo;
  final ProviderRef ref;
  AuthController({
    required this.authRepo,
    required this.ref,
  });

  Future<UserModel?> getCurrentUserData() async {
    UserModel? user = await authRepo.getCurrentUserData();
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepo.signInwithPhone(context, phoneNumber);
  }

  void verifyOtp(BuildContext context, String verificationId, String userOTP) {
    authRepo.verifyOtp(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  void saveUserToFirebase(BuildContext context, File? profilePic, String name) {
    authRepo.saveUserToFirebase(
      name: name,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );
  }

  Stream<UserModel> userDataId(String userId) {
    return authRepo.userDataId(userId);
  }

  void setUserState(bool isOnline) {
    authRepo.setUserstate(isOnline);
  }
}
