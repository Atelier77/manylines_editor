import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/glossary/add_entry.dart';
import 'glossary_entry_tile.dart';

class GlossaryPanel extends StatelessWidget {
  const GlossaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    
    final project = projectState.selectedProject;
    final glossary = project?.glossary ?? [];
    final isDarkMode = settingState.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    if (project == null) {
      return Container(
        width: 300,
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        child: const Center(child: Text('Выберите проект')),
      );
    }

    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF603D2E),
          ),
        ),
        color: isDarkMode ? Colors.grey[900] : Color(0xFFFFEDEB),
      ),
      child: Column(
        children: [
          _buildHeader(project.name, textColor, isDarkMode, context),
          Expanded(
            child: glossary.isEmpty
                ? _buildEmptyState(isDarkMode)
                : ListView.builder(
                    itemCount: glossary.length,
                    itemBuilder: (context, index) {
                      final entry = glossary[index];
                      return GlossaryEntryTile(
                        entry: entry,
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        borderColor: borderColor,
                        onUpdateDefinition: (defId, definition) => 
                            projectState.updateGlossaryDefinition(defId, definition),
                        onToggleDefinition: (defId) => 
                            projectState.toggleGlossaryDefinition(defId),
                        onDeleteDefinition: (entryId, defId) => 
                            projectState.deleteGlossaryDefinition(entryId, defId),
                        onToggleExpand: () => projectState.toggleGlossaryEntry(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String documentName, Color textColor, bool isDarkMode, BuildContext context) {
    return Container(
      decoration: BoxDecoration( 
        color: isDarkMode ? Color(0xFF603D2E) : Color(0xFFAB73D3),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF603D2E),
            width: 3,
            ),
          ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.book, size: 20,
          color: Color.fromARGB(255, 255, 255, 255)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              documentName + ' Glossary',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Ostrovsky',
                color: Color.fromARGB(255, 255, 255, 255),),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Глоссарий пуст', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            'Выделите текст и нажмите кнопку',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

  Widget buildAddEntrySection(
    String selectedText, 
    Color textColor, 
    bool isDarkMode, 
    String documentId,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isDarkMode ? Colors.blue[900]!.withOpacity(0.3) : Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выделенный текст:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              border: Border.all(color: Colors.blue[700]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(selectedText, style: TextStyle(color: textColor)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => AddGlossaryEntryFeature.execute(
                context,
                selectedText, 
                documentId,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить в глоссарий'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
