import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manylines_editor/entities/project/project_repository.dart';
import 'package:manylines_editor/entities/setting/setting_repository.dart';
import 'package:manylines_editor/features/project/create_project.dart';

void main() {
  group('CreateProjectFeature', () {
    late ProjectRepository projectRepo;
    late SettingRepository settingRepo;

    setUp(() {
      projectRepo = ProjectRepository();
      settingRepo = SettingRepository();
    });

    tearDown(() {
      projectRepo.dispose();
      settingRepo.dispose();
    });

    test('ProjectRepository can add a project', () {
      final initialCount = projectRepo.projects.length;
      
      projectRepo.addProject('Test Project');
      
      expect(projectRepo.projects.length, equals(initialCount + 1));
      expect(projectRepo.projects.last.name, equals('Test Project'));
    });

    test('Created project has valid ID', () {
      projectRepo.addProject('Test Project');
      
      final project = projectRepo.projects.last;
      expect(project.id, isNotEmpty);
      expect(project.id, isA<String>());
    });

    test('Created project has empty documents list', () {
      projectRepo.addProject('Test Project');
      
      final project = projectRepo.projects.last;
      expect(project.documents, isNotNull);
      expect(project.documents, isEmpty);
    });

    test('Created project has empty glossary', () {
      projectRepo.addProject('Test Project');
      
      final project = projectRepo.projects.last;
      expect(project.glossary, isNotNull);
      expect(project.glossary, isEmpty);
    });

    testWidgets('Show dialog displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: projectRepo),
            ChangeNotifierProvider.value(value: settingRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CreateProjectFeature.show(context),
                  child: const Text('Create'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Новый проект'), findsOneWidget);
      expect(find.text('Название проекта'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Создать'), findsOneWidget);
    });

    testWidgets('Can create project through dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: projectRepo),
            ChangeNotifierProvider.value(value: settingRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CreateProjectFeature.show(context),
                  child: const Text('Create'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Dialog Test Project');
      await tester.pump();

      await tester.tap(find.text('Создать'));
      await tester.pumpAndSettle();

      expect(
        projectRepo.projects.any((p) => p.name == 'Dialog Test Project'),
        isTrue,
      );

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Validation prevents empty project name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: projectRepo),
            ChangeNotifierProvider.value(value: settingRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CreateProjectFeature.show(context),
                  child: const Text('Create'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '   ');
      await tester.pump();

      await tester.tap(find.text('Создать'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}