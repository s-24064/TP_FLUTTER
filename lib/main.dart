import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_services.dart';
import 'page/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}