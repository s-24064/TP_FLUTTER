import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_services.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';
  String _sort = 'recent';

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NoteService>();

    final notes = _query.isEmpty
        ? service.getSortedNotes(_sort)
        : service.search(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc-Notes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sort = value;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'recent', child: Text('Récent')),
              const PopupMenuItem(value: 'old', child: Text('Ancien')),
              const PopupMenuItem(value: 'az', child: Text('Titre A-Z')),
              const PopupMenuItem(value: 'za', child: Text('Titre Z-A')),
            ],
          ),
          Consumer<NoteService>(
            builder: (_, service, __) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Center(child: Text('${service.count}')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),

      body: notes.isEmpty
          ? Center(
              child: Text(
                _query.isEmpty ? 'Aucune note' : 'Aucun résultat',
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (_, index) {
                final note = notes[index];

                return ListTile(
                  title: Text(note.titre),
                  subtitle: Text(note.contenu),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailNotePage(note: note),
                      ),
                    );
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateNotePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}