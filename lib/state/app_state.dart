import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/comment.dart';
import '../models/model_parsing.dart';
import '../models/project.dart';
import '../services/mock_auth_service.dart';
import '../services/project_repository.dart';

/// Loading lifecycle of the initial data.
enum AppStatus { loading, ready, error }

/// Holds the in-memory session and the mutable project data for the app.
///
/// Initial data is loaded once from the read-only JSON assets. Every runtime
/// change (new projects, favorites, comments) lives only in memory and is lost
/// when the app restarts, which is the intended behavior.
class AppState extends ChangeNotifier {
  AppState({ProjectRepository? repository, MockAuthService? authService})
      : _repository = repository ?? const AssetProjectRepository(),
        _authService = authService ?? const MockAuthService();

  final ProjectRepository _repository;
  final MockAuthService _authService;

  AppStatus _status = AppStatus.loading;
  String? _errorMessage;
  List<AppUser> _users = const [];
  List<Project> _projects = const [];
  List<Comment> _comments = const [];
  AppUser? _currentUser;
  final Map<String, Set<String>> _favoritesByUser = {};

  AppStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  List<Project> get projects => List<Project>.unmodifiable(_projects);

  List<Project> get myProjects {
    final user = _currentUser;
    if (user == null) {
      return const [];
    }
    return _projects
        .where((project) => project.ownerId == user.id)
        .toList(growable: false);
  }

  List<Project> get favoriteProjects {
    final favorites = _currentFavorites;
    if (favorites.isEmpty) {
      return const [];
    }
    return _projects
        .where((project) => favorites.contains(project.id))
        .toList(growable: false);
  }

  Set<String> get _currentFavorites =>
      _favoritesByUser[_currentUser?.id] ?? const <String>{};

  /// Loads the JSON assets. Safe to call again to retry after an error.
  Future<void> load() async {
    _status = AppStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _repository.load();
      _users = data.users;
      _projects = data.projects;
      _comments = data.comments;
      _status = AppStatus.ready;
    } on DataParseException catch (error) {
      _errorMessage = error.message;
      _status = AppStatus.error;
    } catch (_) {
      _errorMessage = 'Ocorreu um erro inesperado ao carregar os dados.';
      _status = AppStatus.error;
    }
    notifyListeners();
  }

  /// Attempts to log in. Returns `true` on success.
  bool login(String username, String password) {
    final user = _authService.authenticate(_users, username, password);
    if (user == null) {
      return false;
    }
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    if (_currentUser == null) {
      return;
    }
    _currentUser = null;
    notifyListeners();
  }

  /// Registers a new project owned by the current user.
  Project addProject({
    required String name,
    required String description,
    required List<String> languages,
    required List<String> technologies,
    required ProjectStatus status,
  }) {
    final owner = _currentUser;
    if (owner == null) {
      throw StateError('É necessário entrar para cadastrar projetos.');
    }
    final project = Project(
      id: _generateId('p'),
      name: name.trim(),
      description: description.trim(),
      languages: languages,
      technologies: technologies,
      status: status,
      ownerId: owner.id,
    );
    _projects = [..._projects, project];
    notifyListeners();
    return project;
  }

  bool isFavorite(String projectId) => _currentFavorites.contains(projectId);

  void toggleFavorite(String projectId) {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    final favorites = _favoritesByUser.putIfAbsent(user.id, () => <String>{});
    if (!favorites.add(projectId)) {
      favorites.remove(projectId);
    }
    notifyListeners();
  }

  List<Comment> commentsFor(String projectId) {
    final comments = _comments
        .where((comment) => comment.projectId == projectId)
        .toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  /// Adds a comment authored by the current user. Throws when logged out.
  Comment addComment({required String projectId, required String content}) {
    final author = _currentUser;
    if (author == null) {
      throw StateError('É necessário entrar para comentar.');
    }
    final comment = Comment(
      id: _generateId('c'),
      projectId: projectId,
      authorId: author.id,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    _comments = [..._comments, comment];
    notifyListeners();
    return comment;
  }

  Project? projectById(String id) {
    for (final project in _projects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }

  AppUser? userById(String id) {
    for (final user in _users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  String ownerName(String ownerId) =>
      userById(ownerId)?.displayName ?? 'Usuário desconhecido';

  String _generateId(String prefix) =>
      '$prefix${DateTime.now().microsecondsSinceEpoch}';
}
