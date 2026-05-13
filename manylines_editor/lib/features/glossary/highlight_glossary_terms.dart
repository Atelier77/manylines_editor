import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../entities/project/project_repository.dart';
import '../../entities/glossary_entry/glossary_entry.dart';

class GlossaryHighlightFeature {

  static void applyHighlights(
    quill.QuillController controller,
    ProjectRepository projectRepo,
  ) {
    final glossary = projectRepo.selectedProject?.glossary ?? [];
    if (glossary.isEmpty) return;

    final document = controller.document;
    final text = document.toPlainText();
    
    final highlights = <Map<String, dynamic>>[];
    
    for (final entry in glossary) {
      final term = entry.term.trim();
      if (term.isEmpty) continue;
      
      final regex = RegExp(
        r'\b' + RegExp.escape(term) + r'\b',
        caseSensitive: false,
      );
      
      for (final match in regex.allMatches(text)) {
        highlights.add({
          'start': match.start,
          'end': match.end,
          'termId': entry.id,
          'term': term,
        });
      }
    }
    
    for (final highlight in highlights) {
      final start = highlight['start'] as int;
      final end = highlight['end'] as int;
      final termId = highlight['termId'] as String;
      
      controller.formatText(
        start,
        end - start,
        quill.BackgroundAttribute('#16DB9320'),
      );
      
      controller.formatText(
        start,
        end - start,
        quill.LinkAttribute('glossary:$termId'),
      );
    }
  }

  static void clearHighlights(quill.QuillController controller) {
    final document = controller.document;
    final text = document.toPlainText();
    
    if (text.isEmpty) return;
    
    controller.formatText(
      0,
      text.length,
      quill.BackgroundAttribute(null),
    );
    
    controller.formatText(
      0,
      text.length,
      quill.LinkAttribute(null),
    );
  }

  static void handleTermTap(
    quill.QuillController controller,
    int position,
    ProjectRepository projectRepo,
  ) {
    final document = controller.document;
    final attrs = document.collectStyle(position, 1);
    
    final linkAttr = attrs.attributes[quill.Attribute.link.key];
    if (linkAttr != null) {
      final linkValue = linkAttr.toString();
      if (linkValue.startsWith('glossary:')) {
        final termId = linkValue.split(':').last;
        projectRepo.openGlossaryPanel();
        projectRepo.highlightGlossaryTerm(termId);
      }
    }
  }
}