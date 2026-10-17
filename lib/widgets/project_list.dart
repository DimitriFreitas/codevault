import 'package:flutter/material.dart';

import '../models/project.dart';
import '../screens/project_detail_screen.dart';
import '../state/app_scope.dart';
import '../utils/auth_guard.dart';
import 'project_card.dart';

/// Scrollable list of [ProjectCard]s shared by the project list, my-projects
/// and favorites screens. Shows [emptyState] when there is nothing to display.
class ProjectList extends StatelessWidget {
  const ProjectList({
    super.key,
    required this.projects,
    required this.emptyState,
  });

  final List<Project> projects;
  final Widget emptyState;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (projects.isEmpty) {
      return emptyState;
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: projects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          ownerName: state.ownerName(project.ownerId),
          isFavorite: state.isFavorite(project.id),
          onToggleFavorite: () => _toggleFavorite(context, project.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProjectDetailScreen(projectId: project.id),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(BuildContext context, String projectId) async {
    final authenticated = await ensureAuthenticated(
      context,
      reason: 'Entre para favoritar projetos.',
    );
    if (!authenticated || !context.mounted) {
      return;
    }
    AppScope.read(context).toggleFavorite(projectId);
  }
}
