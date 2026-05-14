import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../entities/project/project_repository.dart';

class GlossaryHighlightFeature {
  static const String lightModeColor = '#FFB07156';
  static const String darkModeColor = '#FF603D2E';

  static void applyHighlights(
    quill.QuillController controller,
    ProjectRepository projectRepo,
    bool isDarkMode
  ) {
    try {
      final glossary = projectRepo.selectedProject?.glossary ?? [];
      if (glossary.isEmpty) return;

      final document = controller.document;
      final text = document.toPlainText();
      final highlightColor = isDarkMode ? darkModeColor : lightModeColor;
      
      for (final entry in glossary) {
        final term = entry.term.trim();
        if (term.isEmpty) continue;
        
        final regex = RegExp(
          r'\b' + RegExp.escape(term) + r'\b',
          caseSensitive: false,
        );
        
        for (final match in regex.allMatches(text)) {
          final start = match.start;
          final end = match.end;
          
          controller.formatText(
            start,
            end - start,
            quill.BackgroundAttribute(highlightColor),
          );
        }
      }
    } catch (e) {
      debugPrint('Ошибка applyHighlights: $e');
    }
  }

  static void clearHighlights(quill.QuillController controller) {
    try {
      final document = controller.document;
      final text = document.toPlainText();
      
      if (text.isEmpty) return;
      
      controller.formatText(
        0,
        text.length,
        quill.BackgroundAttribute(null),
      );
    } catch (e) {
      debugPrint('Ошибка clearHighlights: $e');
    }
  }

  static bool handleTermTap(
    quill.QuillController controller,
    int position,
    ProjectRepository projectRepo,
  ) {
    try {
      final glossary = projectRepo.selectedProject?.glossary ?? [];
      if (glossary.isEmpty) return false;

      final document = controller.document;
      final text = document.toPlainText();
      
      final word = _getWordAtPosition(text, position);
      if (word.isEmpty) return false;
      
      for (final entry in glossary) {
        final term = entry.term.trim().toLowerCase();
        if (term.toLowerCase() == word.toLowerCase()) {
          projectRepo.openGlossaryPanel();
          projectRepo.highlightGlossaryTerm(entry.id);
          
          return true;
        }
      }
      
      debugPrint('Слово "$word" не найдено в глоссарии');
      return false;
    } catch (e) {
      debugPrint('Ошибка handleTermTap: $e');
      return false;
    }
  }

  static String _getWordAtPosition(String text, int position) {
    if (text.isEmpty || position < 0 || position >= text.length) {
      return '';
    }
    
    int start = position;
    while (start > 0 && _isWordChar(text[start - 1])) {
      start--;
    }
    
    int end = position;
    while (end < text.length && _isWordChar(text[end])) {
      end++;
    }
    
    if (start >= end) return '';
    return text.substring(start, end).trim();
  }

  static bool _isWordChar(String char) {
    return RegExp(r'[a-zA-Zа-яА-Я0-9_]').hasMatch(char);
  }
}