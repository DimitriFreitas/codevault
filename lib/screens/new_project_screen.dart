import 'package:flutter/material.dart';

import '../models/project.dart';
import '../state/app_scope.dart';

/// Form to register a new project. Pops with `true` on success.
class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _languagesController = TextEditingController();
  final _technologiesController = TextEditingController();
  ProjectStatus _status = ProjectStatus.planning;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _languagesController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  List<String> _parseList(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);

  String? _validateList(String? value, String label) {
    if (value == null || _parseList(value).isEmpty) {
      return 'Informe ao menos um item para $label.';
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    AppScope.read(context).addProject(
      name: _nameController.text,
      description: _descriptionController.text,
      languages: _parseList(_languagesController.text),
      technologies: _parseList(_technologiesController.text),
      status: _status,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo projeto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: const Key('project_name'),
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome do projeto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do projeto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('project_description'),
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a descrição do projeto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('project_languages'),
                controller: _languagesController,
                decoration: const InputDecoration(
                  labelText: 'Linguagens de programação',
                  helperText: 'Separe por vírgulas. Ex.: Dart, Python',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateList(value, 'as linguagens'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('project_technologies'),
                controller: _technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Tecnologias utilizadas',
                  helperText: 'Separe por vírgulas. Ex.: Flutter, PostgreSQL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateList(value, 'as tecnologias'),
              ),
              const SizedBox(height: 24),
              Text(
                'Status de desenvolvimento',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in ProjectStatus.values)
                    ChoiceChip(
                      key: Key('status_${status.name}'),
                      label: Text(status.label),
                      selected: _status == status,
                      onSelected: (_) => setState(() => _status = status),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                key: const Key('project_submit'),
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text('Cadastrar projeto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
