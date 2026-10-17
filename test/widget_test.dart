import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codevault/main.dart';
import 'package:codevault/models/app_user.dart';
import 'package:codevault/models/comment.dart';
import 'package:codevault/models/model_parsing.dart';
import 'package:codevault/models/project.dart';
import 'package:codevault/services/project_repository.dart';

class FakeRepository implements ProjectRepository {
  @override
  Future<AppData> load() async => AppData(
        users: const [
          AppUser(
            id: 'u1',
            displayName: 'Ana Souza',
            username: 'ana.souza',
            password: 'ana123',
          ),
          AppUser(
            id: 'u2',
            displayName: 'Bruno Lima',
            username: 'bruno.lima',
            password: 'bruno123',
          ),
        ],
        projects: const [
          Project(
            id: 'p1',
            name: 'Projeto Teste',
            description: 'Descrição do projeto de teste.',
            languages: ['Dart'],
            technologies: ['Flutter'],
            status: ProjectStatus.inDevelopment,
            ownerId: 'u1',
          ),
          Project(
            id: 'p2',
            name: 'Segundo Projeto',
            description: 'Outra descrição.',
            languages: ['Python'],
            technologies: ['Django'],
            status: ProjectStatus.completed,
            ownerId: 'u2',
          ),
        ],
        comments: [
          Comment(
            id: 'c1',
            projectId: 'p1',
            authorId: 'u2',
            content: 'Comentário inicial.',
            createdAt: DateTime.utc(2026, 9, 2, 14, 30),
          ),
        ],
      );
}

/// Repository whose data loading always fails (used to test the error state).
class FailingRepository implements ProjectRepository {
  @override
  Future<AppData> load() async =>
      throw const DataParseException('Falha simulada ao ler os arquivos.');
}

/// Repository that loads successfully but with no data (empty states).
class EmptyRepository implements ProjectRepository {
  @override
  Future<AppData> load() async =>
      const AppData(users: [], projects: [], comments: []);
}

Future<void> pumpApp(WidgetTester tester, [ProjectRepository? repository]) async {
  // Use a tall surface so form screens fit without scrolling in tests.
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(CodeVaultApp(repository: repository ?? FakeRepository()));
  await tester.pumpAndSettle();
}

Future<void> popTopRoute(WidgetTester tester) async {
  Navigator.of(tester.element(find.byType(Navigator))).pop();
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester, String username, String password) async {
  await tester.tap(find.byKey(const Key('new_project_fab')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('login_username')), username);
  await tester.enterText(find.byKey(const Key('login_password')), password);
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
  // Dismiss the post-login screen (New Project) to return to the catalog.
  await popTopRoute(tester);
  // Let the login success snackbar expire so later steps assert fresh UI.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> logout(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('drawer_logout')));
  await tester.pumpAndSettle();
}

Future<void> openDrawerRoute(WidgetTester tester, Key key) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('exibe a lista de projetos carregada', (tester) async {
    await pumpApp(tester);

    expect(find.text('Projeto Teste'), findsOneWidget);
    expect(find.text('Segundo Projeto'), findsOneWidget);
  });

  testWidgets('abre os detalhes com todas as informações', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Projeto Teste'));
    await tester.pumpAndSettle();

    expect(find.text('Descrição do projeto de teste.'), findsOneWidget);
    expect(find.text('Dart'), findsWidgets);
    expect(find.text('Flutter'), findsWidgets);
    expect(find.text('Em desenvolvimento'), findsWidgets);
    expect(find.text('Comentário inicial.'), findsOneWidget);
  });

  testWidgets('exige login para cadastrar projeto', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('new_project_fab')));
    await tester.pumpAndSettle();

    expect(find.text('Acesse sua conta'), findsOneWidget);
  });

  testWidgets('rejeita credenciais inválidas', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('new_project_fab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login_username')), 'invalido');
    await tester.enterText(find.byKey(const Key('login_password')), 'errado');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Usuário ou senha inválidos.'), findsOneWidget);
  });

  testWidgets('cadastra um projeto após o login', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ana.souza', 'ana123');

    await tester.tap(find.byKey(const Key('new_project_fab')));
    await tester.pumpAndSettle();
    expect(find.text('Novo projeto'), findsWidgets);

    await tester.enterText(find.byKey(const Key('project_name')), 'Meu Novo App');
    await tester
        .enterText(find.byKey(const Key('project_description')), 'Descrição nova.');
    await tester.enterText(find.byKey(const Key('project_languages')), 'Dart');
    await tester.enterText(find.byKey(const Key('project_technologies')), 'Flutter');
    await tester.tap(find.byKey(const Key('project_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('new_project_fab')), findsOneWidget);
    expect(find.text('Projeto cadastrado com sucesso!'), findsOneWidget);
    expect(find.text('Meu Novo App'), findsOneWidget);

    // The same project must show up in the owner's "Meus projetos".
    await openDrawerRoute(tester, const Key('drawer_my_projects'));
    expect(find.text('Meu Novo App'), findsOneWidget);
  });

  testWidgets('logout encerra a sessão e volta a exigir login', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ana.souza', 'ana123');
    await logout(tester);

    await tester.tap(find.byKey(const Key('new_project_fab')));
    await tester.pumpAndSettle();
    expect(find.text('Acesse sua conta'), findsOneWidget);
  });

  testWidgets('favorita um projeto e lista em Favoritos', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ana.souza', 'ana123');

    await tester.tap(find.byKey(const Key('favorite_p1')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsWidgets);

    await openDrawerRoute(tester, const Key('drawer_favorites'));
    expect(find.text('Projeto Teste'), findsWidgets);
  });

  testWidgets('favoritos são isolados por usuário', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ana.souza', 'ana123');
    await tester.tap(find.byKey(const Key('favorite_p1')));
    await tester.pumpAndSettle();
    await logout(tester);

    await login(tester, 'bruno.lima', 'bruno123');
    await openDrawerRoute(tester, const Key('drawer_favorites'));

    expect(find.text('Você ainda não favoritou projetos'), findsOneWidget);
  });

  testWidgets('publica comentário autenticado', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ana.souza', 'ana123');

    await tester.tap(find.text('Projeto Teste'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('comment_field')), 'Ótimo projeto!');
    await tester.tap(find.byKey(const Key('comment_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Comentário publicado.'), findsOneWidget);
    expect(find.text('Ótimo projeto!'), findsOneWidget);
  });

  testWidgets('visitante vê aviso de comentário em vez do formulário',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Projeto Teste'));
    await tester.pumpAndSettle();

    expect(find.text('Entre para comentar neste projeto.'), findsOneWidget);
  });

  testWidgets('exibe estado vazio quando não há projetos', (tester) async {
    await pumpApp(tester, EmptyRepository());

    expect(find.text('Nenhum projeto cadastrado'), findsOneWidget);
  });

  testWidgets('exibe tela de erro com nova tentativa quando o carregamento falha',
      (tester) async {
    await pumpApp(tester, FailingRepository());

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.text('Falha simulada ao ler os arquivos.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
