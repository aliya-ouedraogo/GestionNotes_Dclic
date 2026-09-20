import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modele/note.dart';
import './couleurs.dart';

/// Retourne la Note créée/modifiée, ou null si l'utilisateur annule.
Future<Note?> showAddEditNoteDialog(BuildContext context, {Note? existing}) {
  return showDialog<Note>(
    context: context,
    builder: (_) => _AddEditNoteDialog(existing: existing),
  );
}

class _AddEditNoteDialog extends StatefulWidget {
  final Note? existing;
  const _AddEditNoteDialog({this.existing});

  @override
  State<_AddEditNoteDialog> createState() => _AddEditNoteDialogState();
}

class _AddEditNoteDialogState extends State<_AddEditNoteDialog> {
  late final TextEditingController _textCtrl;
  DateTime? _selectedDate;
  late bool _important;
  String? _error;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.existing?.text ?? '');
    _important = widget.existing?.important ?? false;
    _selectedDate = widget.existing != null ? DateTime.tryParse(widget.existing!.date) : null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (_textCtrl.text.trim().isEmpty || _selectedDate == null) {
      setState(() => _error = 'Entrez une note et une date.');
      return;
    }
    final note = Note(
      id: widget.existing?.id,
      text: _textCtrl.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      important: _important,
      done: widget.existing?.done ?? false,
    );
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(isEditing ? 'Modifier une note' : 'Ajouter une note',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Container(width: 50, height: 2, color: AppColors.textDark),
            const SizedBox(height: 20),
            TextField(
              controller: _textCtrl,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: isEditing ? 'Entrez une nouvelle note' : 'Entrez une note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: isEditing ? 'Entrez une nouvelle date' : 'Entrez une date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                isEmpty: _selectedDate == null,
                child: _selectedDate == null
                    ? null
                    : Text(DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Checkbox(
                  value: _important,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _important = v ?? false),
                ),
                const Text('Important', style: TextStyle(color: AppColors.textDark)),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
