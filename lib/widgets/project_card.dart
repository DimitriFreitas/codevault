import 'package:flutter/material.dart';

import '../models/project.dart';
import 'project_status_chip.dart';
import 'tag_chips.dart';

/// Summary card for one project, used across the list, my-projects and
/// favorites screens.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.ownerName,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Project project;
  final String ownerName;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleTechnologies = project.technologies.take(4).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    key: Key('favorite_${project.id}'),
                    visualDensity: VisualDensity.compact,
                    tooltip: isFavorite
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                project.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ProjectStatusChip(status: project.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'por $ownerName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TagChips(tags: visibleTechnologies),
            ],
          ),
        ),
      ),
    );
  }
}
