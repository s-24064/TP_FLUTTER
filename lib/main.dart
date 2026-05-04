import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/note_service.dart';
import 'pages/home_page.dart';

void main() async {
  // Obligatoire avant tout appel async dans main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SharedPreferences avant runApp
  final prefs = await SharedPreferences.getInstance();

  runApp(BlocNotesApp(prefs: prefs));
}

class BlocNotesApp extends StatelessWidget {
  final SharedPreferences prefs;

  const BlocNotesApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Passer prefs au constructeur de NoteService
      create: (_) => NoteService(prefs: prefs),
      child: MaterialApp(
        title: 'Bloc-Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
