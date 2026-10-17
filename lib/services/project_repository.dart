import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/app_user.dart';
import '../models/comment.dart';
import '../models/model_parsing.dart';
import '../models/project.dart';

/// Immutable bundle of the data loaded from the static JSON assets.
class AppData {
  const AppData({
    required this.users,
    required this.projects,
    required this.comments,
  });

  final List<AppUser> users;
  final List<Project> projects;
  final List<Comment> comments;
}

/// Loads the initial application data.
abstract class ProjectRepository {
  Future<AppData> load();
}

/// Reads the read-only JSON assets bundled with the application.
///
/// Assets are never written back to; this class only deserializes them.
class AssetProjectRepository implements ProjectRepository {
  const AssetProjectRepository();

  static const String projectsPath = 'assets/data/projects.json';
  static const String usersPath = 'assets/data/users.json';
  static const String commentsPath = 'assets/data/comments.json';

  @override
  Future<AppData> load() async {
    try {
      final sources = await Future.wait([
        rootBundle.loadString(projectsPath),
        rootBundle.loadString(usersPath),
        rootBundle.loadString(commentsPath),
      ]);

      final projectsRoot = _decodeObject(sources[0], projectsPath);
      final usersRoot = _decodeObject(sources[1], usersPath);
      final commentsRoot = _decodeObject(sources[2], commentsPath);

      return AppData(
        users: _decodeList(usersRoot, 'users', usersPath)
            .map(AppUser.fromJson)
            .toList(growable: false),
        projects: _decodeList(projectsRoot, 'projects', projectsPath)
            .map(Project.fromJson)
            .toList(growable: false),
        comments: _decodeList(commentsRoot, 'comments', commentsPath)
            .map(Comment.fromJson)
            .toList(growable: false),
      );
    } on DataParseException {
      rethrow;
    } on FormatException {
      throw const DataParseException('Um dos arquivos de dados está corrompido.');
    } catch (_) {
      throw const DataParseException(
        'Não foi possível carregar os dados do aplicativo.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String source, String path) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw DataParseException('Formato inválido no arquivo "$path".');
  }

  List<Map<String, dynamic>> _decodeList(
    Map<String, dynamic> root,
    String key,
    String path,
  ) {
    final value = root[key];
    if (value is List) {
      return value.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        throw DataParseException('Item inválido na lista "$key" de "$path".');
      }).toList(growable: false);
    }
    throw DataParseException('Chave "$key" ausente no arquivo "$path".');
  }
}
