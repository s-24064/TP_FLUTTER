import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/connectivity_service.dart';
import 'create_page.dart';
import 'detail_page.dart';
import 'api_notes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';
  bool _estConnecte = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verifierConnexion();
    // Écouter les changements de connexion en temps réel
    ConnectivityService.onConnectivityChanged.listen((connecte) {
      if (mounted) {
        setState(() {
          _estConnecte = connecte;
        });
      }
    });
  }

  Future<void> _verifierConnexion() async {
    final connecte = await ConnectivityService.isConnected();
    if (mounted) {
      setState(() {
        _estConnecte = connecte;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _ouvrirCreation() async {
    final Note? nouvelleNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateNotePage()),
    );
    if (nouvelleNote != null && context.mounted) {
      context.read<NoteService>().addNote(nouvelleNote);
    }
  }

  Future<void> _ouvrirDetail(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailNotePage(note: note)),
    );
    if (!context.mounted) return;

    if (result is Note) {
      context.read<NoteService>().updateNote(result);
    } else if (result == 'deleted') {
      context.read<NoteService>().deleteNote(note.id);
    }
  }

  void _afficherMenuTri(BuildContext context) {
    final service = context.read<NoteService>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trier les notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _optionTri(context, service, TriNotes.dateRecent,
                "Date — récent d'abord", Icons.arrow_downward),
            _optionTri(context, service, TriNotes.dateAncien,
                "Date — ancien d'abord", Icons.arrow_upward),
            _optionTri(context, service, TriNotes.titreAZ, "Titre A → Z",
                Icons.sort_by_alpha),
            _optionTri(context, service, TriNotes.titreZA, "Titre Z → A",
                Icons.sort_by_alpha),
          ],
        ),
      ),
    );
  }

  Widget _optionTri(BuildContext context, NoteService service, TriNotes tri,
      String label, IconData icone) {
    final estSelectionne = service.triActuel == tri;
    return ListTile(
      leading:
          Icon(icone, color: estSelectionne ? Colors.amber[700] : Colors.grey),
      title: Text(label,
          style: TextStyle(
            fontWeight: estSelectionne ? FontWeight.bold : FontWeight.normal,
            color: estSelectionne ? Colors.amber[700] : Colors.black,
          )),
      trailing:
          estSelectionne ? Icon(Icons.check, color: Colors.amber[700]) : null,
      onTap: () {
        service.changerTri(tri);
        Navigator.pop(context);
      },
    );
  }

  Color _hexVersColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formaterDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _labelTri(TriNotes tri) {
    switch (tri) {
      case TriNotes.dateRecent:
        return "Récent d'abord";
      case TriNotes.dateAncien:
        return "Ancien d'abord";
      case TriNotes.titreAZ:
        return "Titre A → Z";
      case TriNotes.titreZA:
        return "Titre Z → A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteService = context.watch<NoteService>();
    final notes =
        _query.isEmpty ? noteService.notes : noteService.search(_query);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        title: const Text('Mes Notes'),
        actions: [
          // Icône statut connexion
          Icon(
            _estConnecte ? Icons.wifi : Icons.wifi_off,
            color: _estConnecte ? Colors.white : Colors.red[200],
          ),
          const SizedBox(width: 4),

          // Bouton vers ApiNotesPage (seulement si connecté)
          IconButton(
            // Si connecté -> Nuage plein, sinon -> Nuage barré ou gris
            icon: Icon(
              _estConnecte ? Icons.cloud : Icons.cloud_off,
              color: _estConnecte ? Colors.white : Colors.white54,
            ),
            tooltip: 'Notes API',
            onPressed: () {
              if (_estConnecte) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiNotesPage()),
                );
              } else {
                // Étape 23 : Afficher un message si non connecté
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Synchronisation API impossible sans connexion ❌'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          // Bouton tri
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Trier',
            onPressed: () => _afficherMenuTri(context),
          ),

          // Compteur notes
          Consumer<NoteService>(
            builder: (context, service, _) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${service.count} note${service.count > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une note...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _query = '';
                          _searchController.clear();
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Bandeau hors ligne
          if (!_estConnecte)
            Container(
              width: double.infinity,
              color: Colors.red[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Mode hors ligne — notes locales uniquement',
                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                  ),
                ],
              ),
            ),

          // Bandeau tri actuel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber[50],
            child: Row(
              children: [
                Icon(Icons.sort, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 6),
                Text(
                  'Tri : ${_labelTri(noteService.triActuel)}',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Liste des notes
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _query.isEmpty
                              ? Icons.note_outlined
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _query.isEmpty ? 'Aucune note' : 'Aucun résultat',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          _query.isEmpty
                              ? 'Appuyez sur + pour créer une note'
                              : 'Essayez un autre mot-clé',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final couleur = _hexVersColor(note.couleur);
                      final apercu = note.contenu.length > 30
                          ? '${note.contenu.substring(0, 30)}...'
                          : note.contenu;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _ouvrirDetail(note),
                          borderRadius: BorderRadius.circular(12),
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
                                Text(note.titre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(height: 4),
                                Text(apercu,
                                    style:
                                        const TextStyle(color: Colors.black54)),
                                SizedBox(height: 8),
                                Text(_formaterDate(note.dateCreation),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ouvrirCreation,
        backgroundColor: Colors.amber[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
