import 'package:flutter_test/flutter_test.dart';
import 'package:manylines_editor/entities/project/project_repository.dart';
import 'package:manylines_editor/entities/project/project.dart';

void main() {
  group('ProjectRepository', () {
    late ProjectRepository repository;

    setUp(() {
      repository = ProjectRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('Initial state has no selected project', () {
      expect(repository.selectedProject, isNull);
    });

    test('Initial projects list is empty', () {
      expect(repository.projects, isNotNull);
      expect(repository.projects, isEmpty);
    });

    test('Can select a project', () {
      final project = Project(
        id: '1', 
        name: 'Test Project',
        documents: [],
      );
      repository.selectProject(project);
      
      expect(repository.selectedProject, isNotNull);
      expect(repository.selectedProject?.name, equals('Test Project'));
    });

    test('Can clear selected project', () {
      final project = Project(
        id: '1', 
        name: 'Test Project',
        documents: [],
      );
      repository.selectProject(project);
      expect(repository.selectedProject, isNotNull);
      
      repository.clearSelectedProject();
      expect(repository.selectedProject, isNull);
    });

    test('Can toggle view mode', () {
      expect(repository.isGraphView, isFalse);
      repository.toggleViewMode();
      expect(repository.isGraphView, isTrue);
    });

    test('Can toggle glossary panel', () {
      expect(repository.isGlossaryPanelOpen, isFalse);
      repository.openGlossaryPanel();
      expect(repository.isGlossaryPanelOpen, isTrue);
      repository.toggleGlossaryPanel();
      expect(repository.isGlossaryPanelOpen, isFalse);
    });

    test('Can add glossary entry', () {
      final project = Project(
        id: '1', 
        name: 'Test Project',
        documents: [],
      );
      repository.selectProject(project);
      repository.addGlossaryEntry('Term', 'Definition');
      
      expect(repository.selectedProject?.glossary.length, greaterThanOrEqualTo(1));
      expect(repository.selectedProject?.glossary.first.term, equals('Term'));
    });

    test('Can highlight glossary term', () {
      repository.highlightGlossaryTerm('test-id');
      expect(repository.highlightedGlossaryTermId, equals('test-id'));
    });

    test('Notifies listeners on project change', () {
      bool notified = false;
      repository.addListener(() {
        notified = true;
      });

      final project = Project(
        id: '1', 
        name: 'Test Project',
        documents: [],
      );
      repository.selectProject(project);
      
      expect(notified, isTrue);
    });

    test('Can reorder pinned documents', () {
      final project = Project(
        id: '1', 
        name: 'Test Project',
        documents: [],
      );
      repository.selectProject(project);
      
      expect(() => repository.reorderPinnedDocuments(0, 1), returnsNormally);
    });
  });
}