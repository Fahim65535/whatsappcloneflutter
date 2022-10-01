import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/utils/color.dart';
import 'package:whatsapp_fullstack/features/auth/controller/auth_controller.dart';

class OTPScreen extends ConsumerWidget {
  static const routeName = '/OTP-screen';
  final String verificationId;
  const OTPScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  void verifyOTP(BuildContext context, String userOTP, WidgetRef ref) {
    ref.read(authcontrollerProvider).verifyOtp(
          context,
          verificationId,
          userOTP,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Verify your number'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 15),
            const Text("We have sent an SMS with a code."),
            SizedBox(
              width: size.width * 0.5,
              child: TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '-  -  -  -  -  -',
                  hintStyle: TextStyle(fontSize: 30),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 6) {
                    verifyOTP(context, val.trim(), ref);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
