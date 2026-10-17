import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../utils/auth_guard.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/login_required.dart';
import '../widgets/project_list.dart';

/// Projects owned by the authenticated user. Gated behind login.
class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus projetos')),
      drawer: const AppDrawer(),
      body: !state.isAuthenticated
          ? LoginRequiredView(
              message: 'Entre para ver os projetos que você cadastrou.',
              onLogin: () => _login(context),
            )
          : ProjectList(
              projects: state.myProjects,
              emptyState: const EmptyState(
                icon: Icons.create_new_folder_outlined,
                title: 'Você ainda não cadastrou projetos',
                message:
                    'Use o botão "Novo projeto" no catálogo para começar.',
              ),
            ),
    );
  }

  Future<void> _login(BuildContext context) async {
    await ensureAuthenticated(
      context,
      reason: 'Entre para ver seus projetos.',
    );
  }
}
