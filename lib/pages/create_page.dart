import 'package:flutter/material.dart';
import '../models/note.dart';

class CreateNotePage extends StatefulWidget {
  final Note? note;

  const CreateNotePage({super.key, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titreController = TextEditingController();
  final _contenuController = TextEditingController();
  String _couleurSelectionnee = '#FFE082';

  final List<String> _couleurs = [
    '#FFE082',
    '#EF9A9A',
    '#A5D6A7',
    '#90CAF9',
    '#CE93D8',
    '#FFCC80',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titreController.text = widget.note!.titre;
      _contenuController.text = widget.note!.contenu;
      _couleurSelectionnee = widget.note!.couleur;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  void _sauvegarder() {
    if (_titreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre ne peut pas être vide')),
      );
      return;
    }

    final Note note;

    if (widget.note == null) {
      note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        couleur: _couleurSelectionnee,
        dateCreation: DateTime.now(),
      );
    } else {
      note = widget.note!;
      note.titre = _titreController.text.trim();
      note.contenu = _contenuController.text.trim();
      note.couleur = _couleurSelectionnee;
      note.dateModification = DateTime.now();
    }

    Navigator.pop(context, note);
  }

  Color _hexVersColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final estModification = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(estModification ? 'Modifier la note' : 'Nouvelle note'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _sauvegarder,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titreController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Titre de la note',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _contenuController,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Contenu...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            const Text(
              'Couleur :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _couleurs.map((hex) {
                final estSelectionnee = hex == _couleurSelectionnee;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _couleurSelectionnee = hex;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _hexVersColor(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: estSelectionnee
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: estSelectionnee
                          ? [
                              const BoxShadow(
                                blurRadius: 6,
                                color: Colors.black26,
                              ),
                            ]
                          : null,
                    ),
                    child: estSelectionnee
                        ? const Icon(Icons.check, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sauvegarder,
                icon: const Icon(Icons.save),
                label: Text(
                  estModification
                      ? 'Enregistrer les modifications'
                      : 'Créer la note',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
