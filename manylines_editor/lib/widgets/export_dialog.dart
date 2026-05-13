import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entities/document/document.dart';
import '../entities/setting/setting_repository.dart';
import '../features/document/export_document.dart';

class ExportDialog extends StatelessWidget {
  final AppDocument doc;

  const ExportDialog({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;
    
    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF603D2E) : const Color(0xFFFFEDEB),
      title: Text(
        'Экспорт документа',
        style: TextStyle(
          fontFamily: 'Ostrovsky',
          color: isDarkMode ? Colors.white : const Color(0xFFB07156),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExportOption(
            context,
            icon: Icons.picture_as_pdf,
            title: 'PDF',
            subtitle: 'Экспорт в PDF формат',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              ExportDocumentFeature.exportToPdf(context, doc);
            },
          ),
          const SizedBox(height: 8),
          _buildExportOption(
            context,
            icon: Icons.print,
            title: 'Печать',
            subtitle: 'Распечатать документ',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              ExportDocumentFeature.printDocument(context, doc);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Отмена',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = context.watch<SettingRepository>().isDarkMode;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Ostrovsky',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFFB07156),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Ostrovsky',
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}