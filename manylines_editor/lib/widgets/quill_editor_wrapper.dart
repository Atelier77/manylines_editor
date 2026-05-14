import 'dart:async';
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
  bool _isDisposed = false;
  Timer? _highlightDebounceTimer;
  
  ProjectRepository? _projectRepo;
  SettingRepository? _settingRepo;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(QuillEditorWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id && !_isDisposed) {
      _initializeController();
    }
  }

  void _initializeController() {
    if (_isDisposed) return;
    
    final repo = context.read<DocumentRepository>();
    _controller = repo.getOrCreateController(widget.document);
    
    _projectRepo = context.read<ProjectRepository>();
    _settingRepo = context.read<SettingRepository>();
    
    _settingRepo?.addListener(_onThemeChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed && _controller != null) {
        _applyGlossaryHighlights();
      }
    });
    
    if (!_isDisposed) {
      _projectRepo?.addListener(_onGlossaryChanged);
    }
  }

  void _onThemeChanged() {
    if (_isDisposed || !mounted || _controller == null) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed && _controller != null) {
        _applyGlossaryHighlights();
      }
    });
  }

  void _onGlossaryChanged() {
    if (_isDisposed || !mounted || _controller == null || _isApplyingHighlights) {
      return;
    }
    
    _highlightDebounceTimer?.cancel();
    _highlightDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed && _controller != null) {
        _applyGlossaryHighlights();
      }
    });
  }

  void _applyGlossaryHighlights() {
    if (_isApplyingHighlights || _controller == null || _isDisposed || !mounted) return;
    
    _isApplyingHighlights = true;
    
    try {
      GlossaryHighlightFeature.clearHighlights(_controller!);
      
      final projectRepo = _projectRepo;
      final settingRepo = _settingRepo;
      
      if (projectRepo == null || settingRepo == null) return;
      
      final isDarkMode = settingRepo.isDarkMode;
            
      GlossaryHighlightFeature.applyHighlights(_controller!, projectRepo, isDarkMode);
    } catch (e) {
      debugPrint('Ошибка подсветки глоссария: $e');
    } finally {
      _isApplyingHighlights = false;
    }
  }

  void _handleDoubleTap() {
    if (_isDisposed || _controller == null || !mounted) return;
    
    try {
      final position = _controller!.selection.baseOffset;
      final projectRepo = _projectRepo;
      
      if (projectRepo == null) return;
      
      final opened = GlossaryHighlightFeature.handleTermTap(
        _controller!,
        position,
        projectRepo,
      );
      
    } catch (e) {
      debugPrint('Ошибка обработки двойного клика: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _highlightDebounceTimer?.cancel();
    
    try {
      _projectRepo?.removeListener(_onGlossaryChanged);
      _settingRepo?.removeListener(_onThemeChanged);
    } catch (e) {
      debugPrint('Ошибка удаления слушателя: $e');
    }
    
    _controller = null;
    _projectRepo = null;
    _settingRepo = null;
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _isDisposed) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
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
                    onPressed: _isDisposed ? null : _addSelectedToGlossary,
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
                  enableInteractiveSelection: true,
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
    if (_isDisposed || !mounted) return;
    
    try {
      final selectedText = _getSelectedText();
      if (selectedText != null) {
        final projectRepo = _projectRepo;
        if (projectRepo == null) return;
        
        projectRepo.addGlossaryEntry(selectedText, '');
        projectRepo.openGlossaryPanel();
      }
    } catch (e) {
      debugPrint('Ошибка добавления в глоссарий: $e');
    }
  }

  String? _getSelectedText() {
    if (_controller == null || _isDisposed) return null;
    
    try {
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
    } catch (e) {
      debugPrint('Ошибка получения текста: $e');
      return null;
    }
  }
}