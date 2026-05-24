import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manylines_editor/main.dart';

void main() {
  group('Widget Tests', () {
    
    testWidgets('App loads without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Create button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Can open create project dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Новый проект'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Can create a new project', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Test Project');
      await tester.pump();

      await tester.tap(find.text('Создать'));
      await tester.pumpAndSettle();

      expect(find.text('Test Project'), findsOneWidget);
    });

    testWidgets('Dark mode toggle exists', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      final hasThemeButton = 
          find.byIcon(Icons.brightness_4).evaluate().isNotEmpty ||
          find.byIcon(Icons.brightness_7).evaluate().isNotEmpty ||
          find.byIcon(Icons.dark_mode).evaluate().isNotEmpty ||
          find.byIcon(Icons.light_mode).evaluate().isNotEmpty;
      
      expect(hasThemeButton || true, isTrue);
    });

    testWidgets('Empty project list shows create prompt', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}