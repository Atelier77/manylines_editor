import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manylines_editor/main.dart';
import 'package:manylines_editor/entities/setting/setting_repository.dart';

void main() {
  group('ManylinesApp', () {
    testWidgets('App loads without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Initial state is light mode', (WidgetTester tester) async {
      await tester.pumpWidget(const ManylinesApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ManylinesApp));
      final settingRepo = Provider.of<SettingRepository>(context, listen: false);
      
      expect(settingRepo.isDarkMode, isFalse);
    });
  });
}