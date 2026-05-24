import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manylines_editor/entities/project/project_repository.dart';
import 'package:manylines_editor/entities/project/project.dart';
import 'package:manylines_editor/entities/setting/setting_repository.dart';
import 'package:manylines_editor/features/project/delete_project.dart';

void main() {
  group('DeleteProjectFeature', () {
    late ProjectRepository projectRepo;
    late SettingRepository settingRepo;

    setUp(() {
      projectRepo = ProjectRepository();
      settingRepo = SettingRepository();
      
      final project = Project(
        id: 'test-1',
        name: 'Test Project',
        documents: [],
      );
      projectRepo.projects.add(project);
    });

    tearDown(() {
      projectRepo.dispose();
      settingRepo.dispose();
    });

    testWidgets('Show confirmation dialog displays correctly', (WidgetTester tester) async {
      final project = projectRepo.projects.first;
      
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
                  onPressed: () => DeleteProjectFeature.showConfirmation(context, project),
                  child: const Text('Delete'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Удалить проект?'), findsOneWidget);
      
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
      
      expect(
        find.textContaining(project.name),
        findsOneWidget,
      );
    });

    testWidgets('Cancel closes dialog without deleting', (WidgetTester tester) async {
      final project = projectRepo.projects.first;
      final initialCount = projectRepo.projects.length;
      
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
                  onPressed: () => DeleteProjectFeature.showConfirmation(context, project),
                  child: const Text('Delete'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(projectRepo.projects.length, equals(initialCount));
      expect(projectRepo.projects.any((p) => p.id == project.id), isTrue);

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Delete button closes dialogs', (WidgetTester tester) async {
      final project = projectRepo.projects.first;
      
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
                  onPressed: () => DeleteProjectFeature.showConfirmation(context, project),
                  child: const Text('Delete'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}