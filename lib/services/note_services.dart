import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  int get count => _notes.length;

  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Note> search(String query) {
    if (query.isEmpty) return notes;

    final q = query.toLowerCase();

    return _notes.where((note) {
      return note.titre.toLowerCase().contains(q) ||
             note.contenu.toLowerCase().contains(q);
    }).toList();
  }
  List<Note> getSortedNotes(String sort) {
  final list = List<Note>.from(_notes);

  switch (sort) {
    case 'recent':
      list.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      break;
    case 'old':
      list.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
      break;
    case 'az':
      list.sort((a, b) => a.titre.compareTo(b.titre));
      break;
    case 'za':
      list.sort((a, b) => b.titre.compareTo(a.titre));
      break;
  }

  return list;
}
}