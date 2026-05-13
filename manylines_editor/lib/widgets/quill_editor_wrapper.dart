import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import '../entities/document/document_repository.dart';
import '../entities/document/document.dart';
import '../entities/project/project_repository.dart';
import '../entities/setting/setting_repository.dart';
import '../features/glossary/highlight_glossary_terms.dart';

class QuillEditorWrapper extends StatefulWidget {
  final AppDocument document;
  final int editorIndex;

  const QuillEditorWrapper({
    super.key,
    required this.document,
    this.editorIndex = 1,
  });

  @override
  State<QuillEditorWrapper> createState() => _QuillEditorWrapperState();
}

class _QuillEditorWrapperState extends State<QuillEditorWrapper> {
  quill.QuillController? _controller;
  bool _isApplyingHighlights = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(QuillEditorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id) {
      _initializeController();
    }
  }

  void _initializeController() {
    final repo = context.read<DocumentRepository>();
    _controller = repo.getOrCreateController(widget.document);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller != null) {
        _applyGlossaryHighlights();
      }
    });
    
    context.read<ProjectRepository>().addListener(_onGlossaryChanged);
  }

  void _onGlossaryChanged() {
    if (_controller != null && mounted && !_isApplyingHighlights) {
      _applyGlossaryHighlights();
    }
  }

  void _applyGlossaryHighlights() {
    if (_isApplyingHighlights || _controller == null) return;
    
    _isApplyingHighlights = true;
    
    try {
      GlossaryHighlightFeature.clearHighlights(_controller!);
      
      final projectRepo = context.read<ProjectRepository>();
      GlossaryHighlightFeature.applyHighlights(_controller!, projectRepo);
    } finally {
      _isApplyingHighlights = false;
    }
  }

  void _handleEditorTap(TapUpDetails details) {
    if (_controller == null) return;
    
    final position = _controller!.selection.baseOffset;
    
    final projectRepo = context.read<ProjectRepository>();
    GlossaryHighlightFeature.handleTermTap(
      _controller!,
      position,
      projectRepo,
    );
  }

  @override
  void dispose() {
    if (mounted) {
      context.read<ProjectRepository>().removeListener(_onGlossaryChanged);
    }
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTapUp: _handleEditorTap,
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < -500) {
          }
        },
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: quill.QuillSimpleToolbar(
                    controller: _controller!,
                    config: const quill.QuillSimpleToolbarConfig(
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showFontSize: true,
                      showAlignmentButtons: true,
                      showListNumbers: true,
                      showListBullets: true,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.book, size: 22),
                    onPressed: _addSelectedToGlossary,
                    tooltip: 'Добавить в глоссарий',
                    color: isDarkMode ? const Color(0xFFAB73D3) : const Color(0xFF16DB93),
                  ),
                ),
              ],
            ),
            Expanded(
              child: quill.QuillEditor(
                key: ValueKey('editor_${widget.document.id}_${widget.editorIndex}'),
                controller: _controller!,
                config: quill.QuillEditorConfig(
                  placeholder: 'Начните печатать...',
                  padding: const EdgeInsets.all(16),
                  customStyleBuilder: (attribute) {
                    if (attribute.key == quill.Attribute.link.key) {
                      final value = attribute.value?.toString();
                      if (value != null && value.startsWith('glossary:')) {

                        return TextStyle(
                          backgroundColor: const Color(0xFF16DB93),
                          color: isDarkMode ? Colors.white : const Color(0xFF603D2E),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF16DB93),
                          fontWeight: FontWeight.w600,
                        );
                      }
                    }
                    return const TextStyle();
                  },
                ),
                focusNode: FocusNode(),
                scrollController: ScrollController(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSelectedToGlossary() {
    final selectedText = _getSelectedText();
    if (selectedText != null) {
      final projectRepo = context.read<ProjectRepository>();
      projectRepo.addGlossaryEntry(selectedText, '');
      projectRepo.openGlossaryPanel();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyGlossaryHighlights();
        }
      });
    }
  }

  String? _getSelectedText() {
    if (_controller == null) return null;
    
    final selection = _controller!.selection;
    if (selection.isCollapsed) return null;
    
    final text = _controller!.document.toPlainText();
    if (selection.baseOffset >= text.length || selection.extentOffset >= text.length) return null;
    
    final start = selection.baseOffset < selection.extentOffset 
        ? selection.baseOffset : selection.extentOffset;
    final end = selection.baseOffset < selection.extentOffset 
        ? selection.extentOffset : selection.baseOffset;
    
    final selectedText = text.substring(start, end);
    return selectedText.trim().isNotEmpty ? selectedText.trim() : null;
  }
}