import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../utils/auth_guard.dart';
import '../widgets/app_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/login_required.dart';
import '../widgets/project_list.dart';

/// Projects favorited by the authenticated user. Gated behind login.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      drawer: const AppDrawer(),
      body: !state.isAuthenticated
          ? LoginRequiredView(
              message: 'Entre para ver os projetos que você favoritou.',
              onLogin: () => _login(context),
            )
          : ProjectList(
              projects: state.favoriteProjects,
              emptyState: const EmptyState(
                icon: Icons.favorite_border,
                title: 'Você ainda não favoritou projetos',
                message:
                    'Toque no coração de um projeto para adicioná-lo aqui.',
              ),
            ),
    );
  }

  Future<void> _login(BuildContext context) async {
    await ensureAuthenticated(
      context,
      reason: 'Entre para ver seus favoritos.',
    );
  }
}
