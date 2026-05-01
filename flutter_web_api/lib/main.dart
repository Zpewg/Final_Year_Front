import 'package:flutter/material.dart';
import 'theme/theme_controller.dart';
import 'views/front_page.dart';
import 'dart:io';


void main() {
  // Add this line right here:
  HttpOverrides.global = DevHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, theme, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Management',
          theme: theme,
          builder: (context, child) {
            return Scaffold(
              body: child,
              floatingActionButton: FloatingActionButton(
                onPressed: () => ThemeController.toggleTheme(),
                child: const Icon(Icons.brightness_6),
              ),
            );
          },
          home: const FrontPage(),
        );
      },
    );
  }
}


class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}


