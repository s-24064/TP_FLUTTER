import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService _apiService = ApiService();

  // Les 3 états de la page
  List<Note> _notes = [];
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _chargerNotes(); // charger au démarrage
  }

  // Charger toutes les notes depuis le serveur
  Future<void> _chargerNotes() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final notes = await _apiService.getAllNotes();
      setState(() {
        _notes = notes;
        _chargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = e.toString();
        _chargement = false;
      });
    }
  }

  // Créer une note via POST
  Future<void> _creerNote() async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: 'Nouvelle note API',
      contenu: 'Créée le ${DateTime.now()}',
      couleur: '#A5D6A7',
      dateCreation: DateTime.now(),
    );

    final succes = await _apiService.createNote(note);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succes
              ? 'Note créée sur le serveur ✅'
              : 'Erreur lors de la création ❌',
        ),
        backgroundColor: succes ? Colors.green : Colors.red,
      ),
    );

    if (succes) {
      setState(() {
        _notes.insert(0, note);
      });
    }
  }

  // Supprimer une note via DELETE
  Future<void> _supprimerNote(Note note, int index) async {
    final succes = await _apiService.deleteNote(note.id);

    if (!mounted) return;

    if (succes) {
      setState(() {
        _notes.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note supprimée ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression ❌'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _hexVersColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Bouton rafraîchir
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerNotes,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),

      // Corps : 3 états possibles
      body: _chargement
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement depuis le serveur...'),
                ],
              ),
            )
          : _erreur != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Impossible de contacter le serveur',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _erreur!,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _chargerNotes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _notes.isEmpty
                  ? const Center(child: Text('Aucune note sur le serveur'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        final couleur = _hexVersColor(note.couleur);

                        // Dismissible = glisser pour supprimer
                        return Dismissible(
                          key: Key(note.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (_) => _supprimerNote(note, index),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: couleur, width: 5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.cloud,
                                          size: 14, color: Colors.blue),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          note.titre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    note.contenu.length > 60
                                        ? '${note.contenu.substring(0, 60)}...'
                                        : note.contenu,
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

      floatingActionButton: FloatingActionButton(
        onPressed: _creerNote,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
