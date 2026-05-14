import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../entities/project/project.dart';
import '../../../entities/project/project_repository.dart';
import '../../../entities/document/document_repository.dart';
import '../../../entities/document/document.dart';
import '../../../entities/setting/setting_repository.dart';
import '../../../features/document/create_document.dart';
import '../../../features/document/delete_document.dart';
import '../../../features/document/toggle_pin.dart';
import '../../../features/document/indent_document.dart';
import '../../../features/document/outdent_document.dart';
import '../../../features/document/export_document.dart';


class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final settingState = context.watch<SettingRepository>();
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;
    final isPanelCollapsed = settingState.isSidePanelCollapsed;
    final isGraphView = projectState.isGraphView;
    
    final leftPanelBg = settingState.isDarkMode ? Colors.grey[900] : Color.fromARGB(255, 255, 245, 244);
    final headerBg = settingState.isDarkMode ? Color.fromARGB(255, 0, 0, 0) : Color(0xFFFFEDEB);
    final borderColor = settingState.isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF603D2E);

    return AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isPanelCollapsed 
      ? 0 
      : (isGraphView ? 800 : 300),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 2,
          ),
        ),
      ),
      child: isPanelCollapsed
          ? const SizedBox.shrink()
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: headerBg,
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF603D2E),
                        width: 3,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF603D2E),
                        ),
                        onPressed: () => projectState.clearSelectedProject(),
                        tooltip: 'Back to projects',
                      ),
                      Expanded(
                        child: Text(
                          projectState.selectedProject?.name ?? '',
                          style: TextStyle(
                            fontSize: 18, 
                            fontFamily: 'Ostrovsky',
                            color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          projectState.isGraphView ? Icons.list : Icons.account_tree,
                          color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Color(0xFF603D2E),
                        ),
                        onPressed: () => projectState.toggleViewMode(),
                        tooltip: projectState.isGraphView ? 'Список' : 'Граф',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: leftPanelBg,
                    child: Column(
                      children: [
                        Expanded(
                          child: Selector<ProjectRepository, bool>(
                            selector: (_, state) => state.isGraphView,
                            builder: (context, isGraphView, _) {
                              return isGraphView 
                                  ? const _DocumentsGraph() 
                                  : const _DocumentsList();
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: borderColor,
                                width: 2,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => CreateDocumentFeature.show(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Новый документ'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: settingState.isDarkMode ? Colors.green[700] : Color(0xFFAB73D3),
                                side: BorderSide(
                                  color: settingState.isDarkMode ? Colors.green[400]! : Color(0xFFAB73D3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  const _DocumentsList();
  
  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final project = projectState.selectedProject;
    
    if (project == null) {
      return const Center(child: Text('Нет проекта'));
    }
    
    final pinnedDocs = project.pinnedDocuments;
    final unpinnedDocs = project.unpinnedDocuments;
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return Column(
      children: [
        if (pinnedDocs.isNotEmpty)
          Container(
            color: isDarkMode ? Color(0xFF16DB93) : Color(0xFF662C90),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pinnedDocs.length,
              onReorder: (oldIndex, newIndex) => projectState.reorderPinnedDocuments(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final doc = pinnedDocs[index];
                final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
                
                return Container(
                  key: ValueKey(doc.id),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFFFFEDEB),
                        width: 7,
                      ),
                    ),
                  ),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFEDEB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Color(0xFFFFEDEB),
                        ),
                      ],
                    ),
                    title: Text(doc.name,
                      style: TextStyle(
                        fontSize: 14, 
                        fontFamily: 'Ostrovsky',
                        color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFFFFEDEB),
                        ),
                      ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.file_download, size: 20, color: isDarkMode ? Colors.white : const Color(0xFFFFEDEB),),
                          onPressed: () => ExportDocumentFeature.show(context, doc),
                          tooltip: 'Экспорт',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),

                        GestureDetector(
                          onTap: () {},
                          child: Checkbox(
                            value: doc.isPinned,
                            activeColor: Color.fromARGB(255, 211, 198, 197),
                            onChanged: (value) {
                              TogglePinFeature.execute(context, doc);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: () => _showDeleteMenu(context, doc),
                          tooltip: 'Меню',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Icon(
                          Icons.drag_handle,
                          color: isDarkMode ? Colors.white54 : Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      final repo = context.read<DocumentRepository>();
                      repo.selectDocument(doc);
                    },
                    onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Container(
            color: isDarkMode ? Color.fromARGB(255, 0, 0, 0) : Color(0xFFFFEDEB),
            child: _buildDismissibleList(project, unpinnedDocs, context),
          ),
        ),
      ],
    );
  }

  void _showDeleteMenu(BuildContext context, AppDocument doc) {
    final isDarkMode = context.read<SettingRepository>().isDarkMode;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB),
        title: Text(
          'Удалить документ?',
          style: TextStyle(
            fontFamily: 'Ostrovsky',
            color: isDarkMode ? Colors.white : const Color(0xFFB07156),
          ),
        ),
        content: Text(
          'Документ "${doc.name}" будет удалён без возможности восстановления.',
          style: TextStyle(
            fontFamily: 'Ostrovsky',
            color: isDarkMode ? Colors.white70 : const Color(0xFFB07156),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              DeleteDocumentFeature.execute(context, doc);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }


  Widget _buildDismissibleList(Project project, List<AppDocument> docs, BuildContext context) {
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
        final actualIndex = project.documents.indexOf(doc);

        String number;
        int rootCount = 0;
        int childCount = 0;
        
        for (int i = 0; i <= index; i++) {
          if (docs[i].parentId == null) {
            rootCount++;
            childCount = 0;
          } else {
            childCount++;
          }
        }
        
        if (doc.parentId == null) {
          number = '$rootCount.';
        } else {
          number = '$rootCount.$childCount';
        }

        return Dismissible(
          key: ValueKey(doc.id),
          direction: DismissDirection.horizontal,
          background: Container(
            color: isDarkMode ? Color.fromARGB(237, 88, 83, 83) : Color.fromARGB(238, 213, 195, 194),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: isDarkMode ? Color.fromARGB(237, 88, 83, 83) : Color.fromARGB(238, 213, 195, 194),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              IndentDocumentFeature.execute(context, actualIndex);
            } else if (direction == DismissDirection.endToStart) {
              OutdentDocumentFeature.execute(context, actualIndex);
            }
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: doc.parentId == null
                  ? (isDarkMode ? const Color.fromARGB(255, 36, 153, 60) : Color(0xFFAB73D3))
                  : (isDarkMode ? const Color.fromARGB(255, 104, 196, 110) : Color.fromARGB(255, 205, 164, 234)),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? (doc.parentId == null ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0))
                      : (doc.parentId == null ? Color(0xFFFFEDEB) : Color(0xFFFFEDEB)),
                ),
              ),
            ),
            child: ListTile(
              selected: isSelected,
              selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      color: doc.parentId == null ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    doc.parentId == null ? Icons.insert_drive_file : Icons.subdirectory_arrow_right,
                    size: 16,
                    color: doc.parentId == null ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ],
              ),
              title: Text(doc.name,
                style: TextStyle(
                  fontSize: 14, 
                  fontFamily: 'Ostrovsky',
                  color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFFFFEDEB),
                ),
              ),
              subtitle: doc.parentId != null ? Text('Поддокумент', style: TextStyle(fontSize: 12, color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color(0xFFFFEDEB))) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.file_download, size: 20, color: isDarkMode ? Colors.white : const Color(0xFFFFEDEB),),
                    onPressed: () => ExportDocumentFeature.show(context, doc),
                    tooltip: 'Экспорт',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),

                  GestureDetector(
                    onTap: () {},
                    child: Checkbox(
                      value: doc.isPinned,
                      activeColor: const Color.fromARGB(255, 92, 34, 110),
                      onChanged: (value) {
                        TogglePinFeature.execute(context, doc);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (doc.parentId != null)
                    Icon(Icons.swipe, size: 16, color: Colors.grey[500]),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showDeleteMenu(context, doc),
                    tooltip: 'Меню',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              onTap: () {
                final repo = context.read<DocumentRepository>();
                repo.selectDocument(doc);
              },
              onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
            ),
          ),
        );
      },
    );
  }
}

class _DocumentsGraph extends StatelessWidget {
  const _DocumentsGraph();

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectRepository>();
    final project = projectState.selectedProject;
    final docs = project?.documents ?? [];
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;
    final pinnedDocs = project?.pinnedDocuments ?? [];

    return Column(
      children: [
        if (pinnedDocs.isNotEmpty)
          Container(
            color: isDarkMode ? const Color(0xFF000000) : Color(0xFFAB73D3),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pinnedDocs.length,
              onReorder: (oldIndex, newIndex) => projectState.reorderPinnedDocuments(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final doc = pinnedDocs[index];
                final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;
                
                return Container(
                  key: ValueKey(doc.id),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Colors.green[700]! : Color(0xFFFFEDEB),
                        width: 7,
                      ),
                    ),
                  ),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Color(0xFFFFEDEB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: isDarkMode ? Colors.green[700] : Color(0xFFFFEDEB),
                        ),
                      ],
                    ),
                    title: Text(doc.name,
                    style: TextStyle(
                      fontSize: 14, 
                      fontFamily: 'Ostrovsky',
                      color: isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color(0xFFFFEDEB),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.file_download, size: 20, color: isDarkMode ? Colors.white : const Color(0xFFFFEDEB),),
                          onPressed: () => ExportDocumentFeature.show(context, doc),
                          tooltip: 'Экспорт',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),

                        GestureDetector(
                          onTap: () {},
                          child: Checkbox(
                            value: doc.isPinned,
                            activeColor: Color.fromARGB(255, 211, 198, 197),
                            onChanged: (value) {
                              TogglePinFeature.execute(context, doc);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: () => _showDeleteMenu(context, doc),
                          tooltip: 'Меню',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Icon(
                          Icons.drag_handle,
                          color: isDarkMode ? Colors.white54 : Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      final repo = context.read<DocumentRepository>();
                      repo.selectDocument(doc);
                    },
                    onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
                  ),
                );
              },
            ),
          ),
        
        Expanded(
          child: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Нет документов', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : InteractiveViewer(
                  constrained: false,
                  minScale: 0.1,
                  maxScale: 3.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(1000),
                  child: Container(
                    color: isDarkMode ? Colors.grey[900] : Color.fromARGB(255, 255, 245, 244),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProjectNode(project!, isDarkMode, context),
                            const SizedBox(height: 60),
                            _buildRootDocuments(docs, isDarkMode, context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProjectNode(Project project, bool isDarkMode, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [Colors.purple[900]!, Colors.purple[700]!]
              : [Colors.purple[400]!, Colors.purple[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDarkMode ? Colors.purple[400]! : Colors.purple[600]!,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder, size: 32, color: Colors.white),
          const SizedBox(width: 16),
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootDocuments(List<AppDocument> docs, bool isDarkMode, BuildContext context) {
    final rootDocs = docs.where((d) => d.parentId == null).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rootDocs.map((doc) => 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _buildDocumentColumn(doc, docs, isDarkMode, context),
        )
      ).toList(),
    );
  }

  Widget _buildDocumentColumn(
    AppDocument doc, 
    List<AppDocument> allDocs, 
    bool isDarkMode, 
    BuildContext context
  ) {
    final children = allDocs.where((d) => d.parentId == doc.id).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDocumentNode(doc, isDarkMode, context),
        
        if (children.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...children.asMap().entries.map((entry) {
            final childDoc = entry.value;
            final isLast = entry.key == children.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  _buildDocumentNode(childDoc, isDarkMode, context),
                  if (allDocs.any((d) => d.parentId == childDoc.id)) ...[
                    const SizedBox(height: 12),
                    _buildDocumentColumn(childDoc, allDocs, isDarkMode, context),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildDocumentNode(AppDocument doc, bool isDarkMode, BuildContext context) {
    final isSelected = context.watch<DocumentRepository>().selectedDocument?.id == doc.id;

    return GestureDetector(
      onTap: () {
        final repo = context.read<DocumentRepository>();
        repo.selectDocument(doc);
      },
      onLongPress: () => context.read<DocumentRepository>().selectSecondDocument(doc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.green[800] : Colors.green[100])
              : (isDarkMode ? Colors.grey[800] : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.green[700]!
                : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              doc.isPinned ? Icons.push_pin : Icons.insert_drive_file,
              color: isSelected ? Colors.green[700] : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              doc.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteMenu(BuildContext context, AppDocument doc) {
    DeleteDocumentFeature.showConfirmation(context, doc);
  }
}