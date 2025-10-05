import 'package:flutter/material.dart';
import 'theme_controller.dart';
import 'front_page.dart';

void main() {
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
