import 'package:flutter/material.dart';
import '../modele/note.dart';
import './couleurs.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleDone;

  const NoteTile({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    decoration: note.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(note.date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            tooltip: note.done ? 'Marquer comme non terminée' : 'Marquer comme terminée',
            icon: Icon(
              note.done ? Icons.check_circle : Icons.circle_outlined,
              color: note.done ? Colors.green : AppColors.textMuted,
              size: 22,
            ),
            onPressed: () => onToggleDone(!note.done),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
