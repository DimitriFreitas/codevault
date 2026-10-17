import 'package:flutter/material.dart';

import 'screens/favorites_screen.dart';
import 'screens/my_projects_screen.dart';
import 'screens/new_project_screen.dart';
import 'screens/project_list_screen.dart';
import 'services/project_repository.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'widgets/error_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CodeVaultApp());
}

/// Root widget: wires the [AppState] into the tree and defines the routes.
class CodeVaultApp extends StatefulWidget {
  const CodeVaultApp({super.key, this.repository});

  /// Injectable data source (used by tests); defaults to the JSON assets.
  final ProjectRepository? repository;

  @override
  State<CodeVaultApp> createState() => _CodeVaultAppState();
}

class _CodeVaultAppState extends State<CodeVaultApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState(repository: widget.repository)..load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'CodeVault',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: const Color(0xFF3F51B5)),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const _RootGate(),
          '/new-project': (_) => const NewProjectScreen(),
          '/my-projects': (_) => const MyProjectsScreen(),
          '/favorites': (_) => const FavoritesScreen(),
        },
      ),
    );
  }
}

/// Chooses what to show based on the data-loading status.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return switch (state.status) {
      AppStatus.loading => const _LoadingScreen(),
      AppStatus.error => Scaffold(
          body: SafeArea(
            child: ErrorView(
              message: state.errorMessage ?? 'Erro ao carregar os dados.',
              onRetry: state.load,
            ),
          ),
        ),
      AppStatus.ready => const ProjectListScreen(),
    };
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando projetos...'),
          ],
        ),
      ),
    );
  }
}
