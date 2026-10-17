import 'package:flutter_test/flutter_test.dart';

import 'package:codevault/models/app_user.dart';
import 'package:codevault/models/model_parsing.dart';
import 'package:codevault/models/project.dart';
import 'package:codevault/services/mock_auth_service.dart';
import 'package:codevault/services/project_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Project.fromJson', () {
    test('lê todos os campos', () {
      final project = Project.fromJson({
        'id': 'p1',
        'name': 'Projeto',
        'description': 'Descrição',
        'languages': ['Dart', 'C'],
        'technologies': ['Flutter'],
        'status': 'completed',
        'ownerId': 'u1',
      });

      expect(project.id, 'p1');
      expect(project.languages, ['Dart', 'C']);
      expect(project.technologies, ['Flutter']);
      expect(project.status, ProjectStatus.completed);
      expect(project.ownerId, 'u1');
    });

    test('lança exceção para status desconhecido', () {
      expect(
        () => Project.fromJson({
          'id': 'p1',
          'name': 'Projeto',
          'description': 'Descrição',
          'languages': ['Dart'],
          'technologies': ['Flutter'],
          'status': 'inexistente',
          'ownerId': 'u1',
        }),
        throwsA(isA<DataParseException>()),
      );
    });

    test('lança exceção quando um campo obrigatório falta', () {
      expect(
        () => Project.fromJson({
          'id': 'p1',
          'name': '',
          'description': 'Descrição',
          'languages': ['Dart'],
          'technologies': ['Flutter'],
          'status': 'planning',
          'ownerId': 'u1',
        }),
        throwsA(isA<DataParseException>()),
      );
    });
  });

  group('MockAuthService', () {
    const users = [
      AppUser(id: 'u1', displayName: 'Ana', username: 'ana', password: '123'),
    ];

    test('autentica credenciais válidas', () {
      const service = MockAuthService();
      expect(service.authenticate(users, 'ana', '123')?.id, 'u1');
      expect(service.authenticate(users, 'ANA', '123')?.id, 'u1');
    });

    test('rejeita credenciais inválidas', () {
      const service = MockAuthService();
      expect(service.authenticate(users, 'ana', 'errada'), isNull);
      expect(service.authenticate(users, 'outro', '123'), isNull);
    });
  });

  group('AssetProjectRepository', () {
    test('carrega e desserializa os assets JSON empacotados', () async {
      final data = await const AssetProjectRepository().load();

      expect(data.users, isNotEmpty);
      expect(data.projects, isNotEmpty);
      expect(data.comments, isNotEmpty);
    });
  });
}
