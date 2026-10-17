import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../utils/auth_guard.dart';
import '../widgets/comment_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/project_status_chip.dart';
import '../widgets/tag_chips.dart';

/// Full project information plus the discussion thread.
///
/// Comments are readable by everyone; composing one requires authentication.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final project = state.projectById(projectId);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Projeto não encontrado',
          message: 'Este projeto não está mais disponível no catálogo.',
        ),
      );
    }

    final comments = state.commentsFor(projectId);
    final isFavorite = state.isFavorite(project.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            key: const Key('detail_favorite'),
            tooltip: isFavorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: () => _toggleFavorite(context, project.id),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            project.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ProjectStatusChip(status: project.status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'por ${state.ownerName(project.ownerId)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('Descrição'),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _SectionTitle('Linguagens'),
          const SizedBox(height: 8),
          TagChips(tags: project.languages),
          const SizedBox(height: 24),
          _SectionTitle('Tecnologias'),
          const SizedBox(height: 8),
          TagChips(tags: project.technologies),
          const Divider(height: 48),
          _SectionTitle('Comentários (${comments.length})'),
          const SizedBox(height: 8),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Nenhum comentário ainda. Seja o primeiro a comentar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            for (final comment in comments)
              CommentTile(
                authorName: state.ownerName(comment.authorId),
                content: comment.content,
                createdAt: comment.createdAt,
              ),
          const SizedBox(height: 16),
          _CommentComposer(projectId: project.id),
        ],
      ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// Comment form shown to authenticated users, or a login prompt otherwise.
class _CommentComposer extends StatefulWidget {
  const _CommentComposer({required this.projectId});

  final String projectId;

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final state = AppScope.read(context);
    state.addComment(projectId: widget.projectId, content: _controller.text);
    _controller.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentário publicado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (!state.isAuthenticated) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.lock_outline),
              const SizedBox(height: 8),
              const Text('Entre para comentar neste projeto.'),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('comment_login'),
                onPressed: () => ensureAuthenticated(
                  context,
                  reason: 'Entre para comentar.',
                ),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            key: const Key('comment_field'),
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Escreva um comentário',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite um comentário.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('comment_submit'),
            onPressed: _submit,
            icon: const Icon(Icons.send),
            label: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}
