import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/utils/color.dart';
import 'package:whatsapp_fullstack/common/utils/utils.dart';
import 'package:whatsapp_fullstack/common/widgets/custom_button.dart';
import 'package:whatsapp_fullstack/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (Country _country) {
        setState(() {
          country = _country;
        });
      },
    );
  }

  void sendNumberForOtp() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authcontrollerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: "Fill out all the fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your Phone number"),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("WhatsApp will need to verify your phone number"),
              const SizedBox(height: 10),
              TextButton(
                onPressed: pickCountry,
                child: const Text("Pick a country"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (country != null) Text("+${country!.phoneCode}"),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: size.width * 0.8,
                    child: TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(hintText: "phone number"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.55),
              SizedBox(
                width: 100,
                child: CustomButton(
                  text: "NEXT",
                  onPressed: sendNumberForOtp,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
