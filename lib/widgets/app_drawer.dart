import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../state/app_scope.dart';

/// Shared navigation drawer: catalog sections plus the auth action.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.currentUser;
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: scheme.primaryContainer,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.folder_special, color: scheme.onPrimaryContainer),
                const SizedBox(height: 12),
                Text(
                  'CodeVault',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.displayName ?? 'Visitante',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            key: const Key('drawer_projects'),
            leading: const Icon(Icons.grid_view_outlined),
            title: const Text('Projetos'),
            onTap: () => _navigate(context, '/'),
          ),
          ListTile(
            key: const Key('drawer_my_projects'),
            leading: const Icon(Icons.person_outline),
            title: const Text('Meus projetos'),
            onTap: () => _navigate(
              context,
              '/my-projects',
              gated: true,
              reason: 'Entre para ver seus projetos.',
            ),
          ),
          ListTile(
            key: const Key('drawer_favorites'),
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Favoritos'),
            onTap: () => _navigate(
              context,
              '/favorites',
              gated: true,
              reason: 'Entre para ver seus favoritos.',
            ),
          ),
          const Divider(),
          if (user == null)
            ListTile(
              key: const Key('drawer_login'),
              leading: const Icon(Icons.login),
              title: const Text('Entrar'),
              onTap: () => _login(context),
            )
          else
            ListTile(
              key: const Key('drawer_logout'),
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => _logout(context),
            ),
        ],
      ),
    );
  }

  Future<void> _navigate(
    BuildContext context,
    String route, {
    bool gated = false,
    String? reason,
  }) async {
    final navigator = Navigator.of(context);
    final state = AppScope.read(context);
    navigator.pop();

    if (gated && !state.isAuthenticated) {
      final result = await navigator.push<bool>(
        MaterialPageRoute(builder: (_) => LoginScreen(reason: reason)),
      );
      if (result != true) {
        return;
      }
    }

    navigator.popUntil((route) => route.isFirst);
    if (route != '/') {
      navigator.pushNamed(route);
    }
  }

  Future<void> _login(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _logout(BuildContext context) {
    final navigator = Navigator.of(context);
    final state = AppScope.read(context);
    navigator.pop();
    state.logout();
    navigator.popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(navigator.context).showSnackBar(
      const SnackBar(content: Text('Sessão encerrada.')),
    );
  }
}
