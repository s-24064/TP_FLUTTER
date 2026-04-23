import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_services.dart';

class CreateNotePage extends StatefulWidget {
  final Note? note;

  const CreateNotePage({super.key, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController contenuController = TextEditingController();

  String couleurSelectionnee = '#FFE082';

  final List<String> couleurs = [
    '#FFE082',
    '#FF8A80',
    '#80D8FF',
    '#A7FFEB',
    '#CCFF90',
    '#FFD180',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titreController.text = widget.note!.titre;
      contenuController.text = widget.note!.contenu;
      couleurSelectionnee = widget.note!.couleur;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Créer note' : 'Modifier note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titreController,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: contenuController,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Contenu'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: couleurs.map((c) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      couleurSelectionnee = c;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        Color(int.parse(c.replaceFirst('#', '0xff'))),
                    child: couleurSelectionnee == c
                        ? const Icon(Icons.check, color: Colors.black)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (titreController.text.isEmpty) return;

                final note = Note(
                  id: widget.note?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  titre: titreController.text,
                  contenu: contenuController.text,
                  couleur: couleurSelectionnee,
                  dateCreation:
                      widget.note?.dateCreation ?? DateTime.now(),
                  dateModification: DateTime.now(),
                );

                if (widget.note == null) {
                  context.read<NoteService>().addNote(note);
                  
                } else {
                  context.read<NoteService>().updateNote(note);
                }

                Navigator.pop(context);
              },
              child: const Text('Sauvegarder'),
            )
          ],
        ),
      ),
    );
  }
}