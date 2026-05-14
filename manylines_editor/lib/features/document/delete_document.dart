import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../entities/document/document.dart';
import '../../entities/document/document_repository.dart';
import '../../entities/project/project_repository.dart';
import '../../entities/setting/setting_repository.dart';

class DeleteDocumentFeature {
  static void showConfirmation(BuildContext context, AppDocument doc) {
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
              execute(context, doc);
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

  static void execute(BuildContext context, AppDocument doc) {
    final projectRepo = Provider.of<ProjectRepository>(context, listen: false);
    final documentRepo = Provider.of<DocumentRepository>(context, listen: false);
    
    documentRepo.deleteDocumentControllers(doc.id);
    
    projectRepo.deleteDocument(doc);
    
    documentRepo.closeEditorIfOpen(doc.id);
  }
}