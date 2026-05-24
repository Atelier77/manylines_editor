import 'package:flutter_test/flutter_test.dart';
import 'package:manylines_editor/entities/setting/setting_repository.dart';

void main() {
  group('SettingRepository', () {
    late SettingRepository repository;

    setUp(() {
      repository = SettingRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('Initial state is light mode', () {
      expect(repository.isDarkMode, isFalse);
    });

    test('Can toggle dark mode', () {
      repository.toggleDarkMode(true);
      expect(repository.isDarkMode, isTrue);

      repository.toggleDarkMode(false);
      expect(repository.isDarkMode, isFalse);
    });

    test('Notifies listeners on theme change', () {
      bool notified = false;
      repository.addListener(() {
        notified = true;
      });

      repository.toggleDarkMode(true);
      expect(notified, isTrue);
    });

    test('Can toggle side panel', () {
      expect(repository.isSidePanelCollapsed, isFalse);
      repository.toggleSidePanel();
      expect(repository.isSidePanelCollapsed, isTrue);
    });
  });
}