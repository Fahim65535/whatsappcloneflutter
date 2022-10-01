import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_fullstack/common/utils/color.dart';
import 'package:whatsapp_fullstack/common/widgets/error.dart';
import 'package:whatsapp_fullstack/common/widgets/loader.dart';
import 'package:whatsapp_fullstack/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_fullstack/features/landing/landing_screen.dart';
import 'package:whatsapp_fullstack/firebase_options.dart';
import 'package:whatsapp_fullstack/route.dart';
import 'package:whatsapp_fullstack/screens/mobile_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Fullstack',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataProvider).when(
          data: (user) {
            if (user == null) {
              return const LandingScreen();
            }
            return const MobileLayoutScreen();
          },
          error: (err, trace) {
            return ErrorScreen(
              text: err.toString(),
            );
          },
          loading: () => const Loader()),
    );
  }
}
