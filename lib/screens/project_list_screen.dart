import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../utils/auth_guard.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_list.dart';

/// Public home screen: the catalog of projects, visible to everyone.
class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('CodeVault')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new_project_fab'),
        onPressed: () => _createProject(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo projeto'),
      ),
      body: ProjectList(
        projects: state.projects,
        emptyState: const EmptyState(
          icon: Icons.folder_off_outlined,
          title: 'Nenhum projeto cadastrado',
          message: 'Cadastre o primeiro projeto para começar o catálogo.',
        ),
      ),
    );
  }

  Future<void> _createProject(BuildContext context) async {
    final authenticated = await ensureAuthenticated(
      context,
      reason: 'Entre para cadastrar um novo projeto.',
    );
    if (!authenticated || !context.mounted) {
      return;
    }
    final result = await Navigator.of(context).pushNamed('/new-project');
    if (!context.mounted || result != true) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Projeto cadastrado com sucesso!')),
    );
  }
}
