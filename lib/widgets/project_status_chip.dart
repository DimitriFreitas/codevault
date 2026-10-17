import 'package:flutter/material.dart';

import '../models/project.dart';

/// Colored pill showing a project's development status (pt-BR label).
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      ProjectStatus.planning => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      ProjectStatus.inDevelopment => (scheme.primaryContainer, scheme.onPrimaryContainer),
      ProjectStatus.paused => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      ProjectStatus.completed => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
