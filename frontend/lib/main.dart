import 'package:flutter/material.dart';
import 'controllers/ebook_library_controller.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EbookLibraryController();

    return MaterialApp(
      title: 'Digital Ebook Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5A2B),
          primary: const Color(0xFF8B5A2B),
        ),
        useMaterial3: true,
      ),
      home: LibraryScreen(controller: controller),
    );
  }
}
