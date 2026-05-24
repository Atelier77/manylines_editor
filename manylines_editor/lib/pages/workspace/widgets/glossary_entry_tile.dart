import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/glossary_entry/glossary_entry.dart';
import '../../../entities/project/project_repository.dart';

class GlossaryEntryTile extends StatefulWidget {
  final GlossaryEntry entry;
  final bool isDarkMode;
  final Color textColor;
  final Color borderColor;
  final Function(String, String) onUpdateDefinition;
  final Function(String) onToggleDefinition;
  final Function(String, String) onDeleteDefinition;
  final VoidCallback onToggleExpand;

  const GlossaryEntryTile({
    super.key,
    required this.entry,
    required this.isDarkMode,
    required this.textColor,
    required this.borderColor,
    required this.onUpdateDefinition,
    required this.onToggleDefinition,
    required this.onDeleteDefinition,
    required this.onToggleExpand,
  });

  @override
  State<GlossaryEntryTile> createState() => _GlossaryEntryTileState();
}

class _GlossaryEntryTileState extends State<GlossaryEntryTile> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (var def in widget.entry.definitions) {
      _controllers[def.id] = TextEditingController(text: def.text);
      _focusNodes[def.id] = FocusNode();
    }
  }

  @override
  void didUpdateWidget(GlossaryEntryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var def in widget.entry.definitions) {
      if (!_controllers.containsKey(def.id)) {
        _controllers[def.id] = TextEditingController(text: def.text);
        _focusNodes[def.id] = FocusNode();
      }
      // ✅ Обновляем текст только если фокус не активен
      else if (_controllers[def.id]!.text != def.text && !_focusNodes[def.id]!.hasFocus) {
        _controllers[def.id]!.text = def.text;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode 
                ? const Color.fromARGB(255, 255, 255, 255) 
                : const Color(0xFF603D2E),
            width: 3,
          ),
        ),
        color: widget.entry.isExpanded
            ? (widget.isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3))
            : (widget.isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Row(
              children: [
                Icon(
                  widget.entry.isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  size: 30,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.entry.term,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Ostrovsky',
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            onTap: widget.onToggleExpand,
          ),
          if (widget.entry.isExpanded)
            ...widget.entry.definitions.map((def) => _buildDefinitionTile(def)),
        ],
      ),
    );
  }

  Widget _buildDefinitionTile(GlossaryDefinition def) {
    final isCollapsed = def.isCollapsed;
    final focusNode = _focusNodes[def.id]!;
    final controller = _controllers[def.id]!;

    return Container(
      decoration: BoxDecoration(
        color: !isCollapsed
            ? (widget.isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : const Color(0xFFFFEDEB))
            : (widget.isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : const Color(0xFFFFEDEB)),
        border: Border(
          top: BorderSide(
            color: widget.isDarkMode
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color(0xFF603D2E),
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => widget.onToggleDefinition(def.id),
            child: Icon(
              isCollapsed ? Icons.radio_button_unchecked : Icons.radio_button_checked,
              color: widget.isDarkMode ? const Color(0xFFB07156) : const Color(0xFFAB73D3),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCollapsed) ...[
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: null,
                    minLines: 3,
                    style: TextStyle(color: widget.textColor),
                    decoration: InputDecoration(
                      hintText: 'Введите определение...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onTap: () {
                      context.read<ProjectRepository>().startGlossaryEditing();
                    },
                    onEditingComplete: () {
                      context.read<ProjectRepository>().stopGlossaryEditing();
                    },
                    onChanged: (value) {
                      widget.onUpdateDefinition(def.id, value);
                    },
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => widget.onToggleDefinition(def.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        _getFirstLine(def.text),
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color(0xFF603D2E),
                          fontStyle: def.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                          fontFamily: 'Ostrovsky',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () {
                      widget.onDeleteDefinition(widget.entry.id, def.id);
                    },
                    tooltip: 'Удалить определение',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFirstLine(String text) {
    if (text.isEmpty) return 'Lorem ipsum...';
    final lines = text.split('\n');

    String firstLine = lines.first;
    String subtext = text;
    if (firstLine.length > 20) {
      firstLine = firstLine.substring(0, 20);
      subtext = text.substring(0, 20) + '...';
    }

    final hasMoreLines = lines.length > 1 || text.length > lines.first.length;
    if (!hasMoreLines) {
      return subtext;
    } else {
      return '$firstLine...';
    }
  }
}