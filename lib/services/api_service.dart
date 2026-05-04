import 'dart:convert';
import 'dart:io'; // Pour gérer les exceptions Socket
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // On définit les headers une seule fois pour la réutilisation
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        // Certains serveurs exigent un User-Agent pour éviter le 403
        'User-Agent': 'Flutter_BlocNotes_App',
      };

  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.take(10).map((json) {
          return Note(
            id: json['id'].toString(),
            titre: json['title'] ?? 'Sans titre',
            contenu: json['body'] ?? '',
            couleur: '#90CAF9',
            dateCreation: DateTime.now(),
          );
        }).toList();
      } else {
        // C'est ici que ton 403 est capturé
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  // POST /posts — Créer une note sur le serveur
  Future<bool> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': note.titre,
          'body': note.contenu,
          'userId': 1,
        }),
      );
      // 201 = Created
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // PUT /posts/id — Modifier une note sur le serveur
  Future<bool> updateNote(Note note) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': note.id,
          'title': note.titre,
          'body': note.contenu,
          'userId': 1,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // DELETE /posts/id — Supprimer une note sur le serveur
  Future<bool> deleteNote(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
