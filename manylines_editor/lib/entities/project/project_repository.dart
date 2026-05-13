import 'package:flutter/foundation.dart';
import 'project.dart';
import '../document/document.dart';
import '../glossary_entry/glossary_entry.dart';

class ProjectRepository extends ChangeNotifier {
  final List<Project> _projects = [
    Project(id: 'p1', name: 'Project 1', documents: []),
    Project(id: 'p2', name: 'Project 2', documents: []),
  ];

  Project? _selectedProject;
  bool _isGraphView = false;
  bool _isGlossaryPanelOpen = false;
  String? _highlightedGlossaryTermId;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isGraphView => _isGraphView;
  bool get isGlossaryPanelOpen => _isGlossaryPanelOpen;
  String? get highlightedGlossaryTermId => _highlightedGlossaryTermId;

  void addProject(String name) {
    _projects.add(Project(
      id: 'p${_projects.length + 1}',
      name: name,
      documents: [],
    ));
    notifyListeners();
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }

  void reorderProjects(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _projects.removeAt(oldIndex);
    _projects.insert(newIndex, item);
    notifyListeners();
  }

  void reorderPinnedDocuments(int oldIndex, int newIndex) {
    if (_selectedProject == null) return;
    
    final pinnedDocs = _selectedProject!.pinnedDocuments;
    if (newIndex > oldIndex) newIndex -= 1;
    
    final doc = pinnedDocs.removeAt(oldIndex);
    final targetDoc = pinnedDocs[newIndex];
    
    final docMainIndex = _selectedProject!.documents.indexOf(doc);
    final targetMainIndex = _selectedProject!.documents.indexOf(targetDoc);
    
    _selectedProject!.documents.removeAt(docMainIndex);
    _selectedProject!.documents.insert(targetMainIndex, doc);
    
    notifyListeners();
  }

  void toggleViewMode() {
    _isGraphView = !_isGraphView;
    notifyListeners();
  }

  void addDocumentToProject(AppDocument document) {
    if (_selectedProject == null) return;
    _selectedProject!.documents.add(document);
    notifyListeners();
  }

  void deleteDocument(AppDocument doc) {
    if (_selectedProject == null) return;
    _selectedProject!.documents.remove(doc);
    notifyListeners();
  }

  void togglePin(AppDocument doc) {
    doc.isPinned = !doc.isPinned;
    notifyListeners();
  }

  void addGlossaryEntry(String term, String definition) {
    if (_selectedProject == null) return;
    
    GlossaryEntry? existingEntry;
    try {
      existingEntry = _selectedProject!.glossary
          .firstWhere((e) => e.term.toLowerCase() == term.toLowerCase());
    } catch (e) {
      existingEntry = null;
    }
    
    if (existingEntry != null) {
      final newDefinition = GlossaryDefinition(
        id: 'def${DateTime.now().millisecondsSinceEpoch}',
        text: definition,
        isActive: false,
      );
      existingEntry.definitions.add(newDefinition);
    } else {
      final newEntry = GlossaryEntry(
        id: 'g${DateTime.now().millisecondsSinceEpoch}',
        term: term,
        definitions: [
          GlossaryDefinition(
            id: 'def${DateTime.now().millisecondsSinceEpoch}',
            text: definition,
            isActive: true,
          ),
        ],
      );
      _selectedProject!.glossary.add(newEntry);
    }
    
    notifyListeners();
  }

  void updateGlossaryDefinition(String definitionId, String newText) {
    if (_selectedProject == null) return;
    
    for (var entry in _selectedProject!.glossary) {
      GlossaryDefinition? def;
      try {
        def = entry.definitions.firstWhere((d) => d.id == definitionId);
      } catch (e) {
        continue;
      }
      
      if (def != null) {
        def.text = newText;
        notifyListeners();
        return;
      }
    }
  }

  void toggleGlossaryDefinition(String definitionId) {
  if (_selectedProject == null) return;
  
  for (var entry in _selectedProject!.glossary) {
    for (var def in entry.definitions) {
      if (def.id == definitionId) {
        def.isCollapsed = !def.isCollapsed;
        notifyListeners();
        return;
      }
    }
  }
}

  void deleteGlossaryDefinition(String entryId, String definitionId) {
    if (_selectedProject == null) return;
    
    GlossaryEntry? entry;
    try {
      entry = _selectedProject!.glossary.firstWhere((e) => e.id == entryId);
    } catch (e) {
      return;
    }
    
    if (entry != null) {
      entry.definitions.removeWhere((d) => d.id == definitionId);
      if (entry.definitions.isEmpty) {
        _selectedProject!.glossary.remove(entry);
      }
      notifyListeners();
    }
  }

  void toggleGlossaryEntry(String entryId) {
    if (_selectedProject == null) return;
    
    try {
      final entry = _selectedProject!.glossary
          .firstWhere((e) => e.id == entryId);
      entry.isExpanded = !entry.isExpanded;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  void openGlossaryPanel() {
    _isGlossaryPanelOpen = true;
    notifyListeners();
  }

  void toggleGlossaryPanel() {
    _isGlossaryPanelOpen = !_isGlossaryPanelOpen;
    notifyListeners();
  }

  void closeGlossaryPanel() {
    _isGlossaryPanelOpen = false;
    notifyListeners();
  }

  void highlightGlossaryTerm(String termId) {
    _highlightedGlossaryTermId = termId;
    notifyListeners();
    
    // ✅ Автоматически убираем подсветку через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      if (_highlightedGlossaryTermId == termId) {
        _highlightedGlossaryTermId = null;
        notifyListeners();
      }
    });
  }
}