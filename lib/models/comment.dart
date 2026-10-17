import 'model_parsing.dart';

/// A comment written by a user on a project.
class Comment {
  const Comment({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: requireString(json, 'id'),
      projectId: requireString(json, 'projectId'),
      authorId: requireString(json, 'authorId'),
      content: requireString(json, 'content'),
      createdAt: requireDateTime(json, 'createdAt'),
    );
  }
}
