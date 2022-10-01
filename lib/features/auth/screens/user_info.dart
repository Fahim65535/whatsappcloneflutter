import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/utils/utils.dart';
import 'package:whatsapp_fullstack/features/auth/controller/auth_controller.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const routeName = '/user-info';
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final nameController = TextEditingController();
  File? image;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void saveUser() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      ref.read(authcontrollerProvider).saveUserToFirebase(
            context,
            image,
            name,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  image == null
                      ? const CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png",
                          ),
                          radius: 60,
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(
                            image!,
                          ),
                          radius: 60,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter your name",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: saveUser,
                    icon: const Icon(
                      Icons.done,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
