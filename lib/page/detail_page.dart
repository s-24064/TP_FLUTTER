import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_services.dart';
import 'create_page.dart';

class DetailNotePage extends StatelessWidget {
  final Note note;

  const DetailNotePage({
    super.key,
    required this.note,
  });

  String formatDate(DateTime date) {
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    return '${date.day} ${mois[date.month - 1]} ${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(note.couleur.replaceFirst('#', '0xff')),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: const Text('Détail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateNotePage(note: note),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer'),
                  content: const Text('Voulez-vous supprimer cette note ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<NoteService>().deleteNote(note.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(formatDate(note.dateCreation)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(note.contenu),
              ),
            ),
          ],
        ),
      ),
    );
  }
}