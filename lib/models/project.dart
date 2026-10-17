import 'model_parsing.dart';

/// Lifecycle stage of a project, with a pt-BR label for the UI.
enum ProjectStatus {
  planning('Planejamento'),
  inDevelopment('Em desenvolvimento'),
  paused('Pausado'),
  completed('Concluído');

  const ProjectStatus(this.label);

  /// Human-readable pt-BR label.
  final String label;

  /// Parses the enum from its JSON name, throwing on unknown values.
  static ProjectStatus parse(String? value) {
    for (final status in values) {
      if (status.name == value) {
        return status;
      }
    }
    throw DataParseException('Status de projeto inválido: "$value".');
  }
}

/// A programming project registered in CodeVault.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.languages,
    required this.technologies,
    required this.status,
    required this.ownerId,
  });

  final String id;
  final String name;
  final String description;
  final List<String> languages;
  final List<String> technologies;
  final ProjectStatus status;
  final String ownerId;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: requireString(json, 'id'),
      name: requireString(json, 'name'),
      description: requireString(json, 'description'),
      languages: requireStringList(json, 'languages'),
      technologies: requireStringList(json, 'technologies'),
      status: ProjectStatus.parse(json['status'] as String?),
      ownerId: requireString(json, 'ownerId'),
    );
  }
}
