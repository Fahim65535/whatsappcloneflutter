import 'package:flutter/material.dart';
import 'package:whatsapp_fullstack/common/widgets/error.dart';
import 'package:whatsapp_fullstack/features/auth/screens/login_screen.dart';
import 'package:whatsapp_fullstack/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_fullstack/features/auth/screens/user_info.dart';
import 'package:whatsapp_fullstack/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_fullstack/features/select_contacts/screens/select_contacts_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );
    case UserInfoScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case SelectContactScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactScreen(),
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(text: "The page does not exist"),
        ),
      );
  }
}
