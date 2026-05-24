import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manylines_editor/main.dart';

void main() {
  group('Integration Tests - UI Flow', () {
    
    testWidgets('App loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Main screen has create button', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Create project dialog opens', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Новый проект'), findsOneWidget);
    });

    testWidgets('Dialog has input field and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Создать'), findsOneWidget);
    });

    testWidgets('Cancel closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Can enter text in project name field', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'My Test Project');
      await tester.pump();

      expect(find.text('My Test Project'), findsOneWidget);
    });

    testWidgets('App remains stable after interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byType(ManylinesApp), findsOneWidget);
      
      if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump(const Duration(milliseconds: 200));
      }
      
      expect(find.byType(ManylinesApp), findsOneWidget);
    });
  });
}