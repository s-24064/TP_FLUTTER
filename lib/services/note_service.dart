import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

enum TriNotes { dateRecent, dateAncien, titreAZ, titreZA }

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  final SharedPreferences _prefs;
  static const String _cle = 'notes_sauvegardees';
  TriNotes _triActuel = TriNotes.dateRecent;

  // Constructeur reçoit l'instance SharedPreferences
  NoteService({required SharedPreferences prefs}) : _prefs = prefs {
    _loadNotes(); // charger les notes au démarrage
  }

  // ─── GETTERS ───────────────────────────────────────────────

  TriNotes get triActuel => _triActuel;
  int get count => _notes.length;

  List<Note> get notes {
    final liste = List<Note>.from(_notes);
    switch (_triActuel) {
      case TriNotes.dateRecent:
        liste.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case TriNotes.dateAncien:
        liste.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case TriNotes.titreAZ:
        liste.sort((a, b) => a.titre.compareTo(b.titre));
        break;
      case TriNotes.titreZA:
        liste.sort((a, b) => b.titre.compareTo(a.titre));
        break;
    }
    return List.unmodifiable(liste);
  }

  // ─── CHARGEMENT ────────────────────────────────────────────

  void _loadNotes() {
    final String? donnees = _prefs.getString(_cle);
    if (donnees != null) {
      final List<dynamic> listeJson = jsonDecode(donnees);
      _notes.clear();
      _notes.addAll(listeJson.map((j) => Note.fromJson(j)).toList());
      notifyListeners();
    }
  }

  // ─── SAUVEGARDE ────────────────────────────────────────────

  Future<void> _saveNotes() async {
    final String donnees = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await _prefs.setString(_cle, donnees);
  }

  // ─── CRUD ──────────────────────────────────────────────────

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
    _saveNotes();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
      _saveNotes();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveNotes();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Note> search(String query) {
    if (query.trim().isEmpty) return notes;
    final q = query.toLowerCase();
    return notes
        .where((n) =>
            n.titre.toLowerCase().contains(q) ||
            n.contenu.toLowerCase().contains(q))
        .toList();
  }

  void changerTri(TriNotes tri) {
    _triActuel = tri;
    notifyListeners();
  }
}
