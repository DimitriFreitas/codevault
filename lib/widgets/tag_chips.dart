import 'package:flutter/material.dart';

/// Compact wrapped list of short text tags (languages, technologies).
class TagChips extends StatelessWidget {
  const TagChips({
    super.key,
    required this.tags,
    this.emptyLabel = 'Não informado',
  });

  final List<String> tags;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (tags.isEmpty) {
      return Text(
        emptyLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(tag, style: theme.textTheme.labelMedium),
            ),
          ),
      ],
    );
  }
}
