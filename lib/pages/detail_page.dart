import 'package:flutter/material.dart';
import '../models/note.dart';
import 'create_page.dart';

class DetailNotePage extends StatelessWidget {
  final Note note;

  const DetailNotePage({super.key, required this.note});

  Color _hexVersColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formaterDate(DateTime date) {
    const mois = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${mois[date.month]} ${date.year} à $h:$m';
  }

  Future<void> _modifierNote(BuildContext context) async {
    final Note? noteModifiee = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateNotePage(note: note)),
    );
    if (noteModifiee != null && context.mounted) {
      Navigator.pop(context, noteModifiee);
    }
  }

  Future<void> _supprimerNote(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmation == true && context.mounted) {
      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _hexVersColor(note.couleur);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: couleur,
        foregroundColor: Colors.black87,
        title: const Text('Détail de la note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () => _modifierNote(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer',
            onPressed: () => _supprimerNote(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.titre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Créée le ${_formaterDate(note.dateCreation)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            if (note.dateModification != null) ...[
              const SizedBox(height: 4),
              Text(
                'Modifiée le ${_formaterDate(note.dateModification!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],

            const Divider(height: 32),

            Text(
              note.contenu.isEmpty ? '(Aucun contenu)' : note.contenu,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
