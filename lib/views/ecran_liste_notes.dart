import 'package:flutter/material.dart';
import '../modele/note.dart';
import '../services/database_helper.dart';
import './couleurs.dart';
import './dialogue_note.dart';
import './dialogue_suppression.dart';
import './carte_note.dart';
import './ecran_connexion.dart';

enum NoteFilter { toutes, importantes, terminees }

class NotesListScreen extends StatefulWidget {
  final String username;
  const NotesListScreen({super.key, required this.username});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  NoteFilter _filter = NoteFilter.toutes;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper.instance.getNotes();
    setState(() => _notes = notes);
  }

  List<Note> get _filteredNotes {
    switch (_filter) {
      case NoteFilter.importantes:
        return _notes.where((n) => n.important).toList();
      case NoteFilter.terminees:
        return _notes.where((n) => n.done).toList();
      case NoteFilter.toutes:
        return _notes;
    }
  }

  Future<void> _addNote() async {
    final note = await showAddEditNoteDialog(context);
    if (note == null) return;
    await DatabaseHelper.instance.insertNote(note);
    await _loadNotes();
    _showSnack('Note enregistrée');
  }

  Future<void> _editNote(Note note) async {
    final updated = await showAddEditNoteDialog(context, existing: note);
    if (updated == null) return;
    await DatabaseHelper.instance.updateNote(updated);
    await _loadNotes();
    _showSnack('Note modifiée');
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDeleteConfirmDialog(context);
    if (!confirmed) return;
    await DatabaseHelper.instance.deleteNote(note.id!);
    await _loadNotes();
    _showSnack('Note supprimée');
  }

  Future<void> _toggleDone(Note note, bool done) async {
    await DatabaseHelper.instance.updateNote(note.copyWith(done: done));
    await _loadNotes();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Mes notes',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout, color: AppColors.textDark),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('Toutes', NoteFilter.toutes),
                const SizedBox(width: 8),
                _filterChip('Importantes', NoteFilter.importantes),
                const SizedBox(width: 8),
                _filterChip('Terminées', NoteFilter.terminees),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notes.length,
                    itemBuilder: (context, i) {
                      final note = notes[i];
                      return NoteTile(
                        note: note,
                        onEdit: () => _editNote(note),
                        onDelete: () => _deleteNote(note),
                        onToggleDone: (v) => _toggleDone(note, v),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: _addNote,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _filterChip(String label, NoteFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold),
      shape: StadiumBorder(side: const BorderSide(color: AppColors.primary)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.note_alt_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            _filter == NoteFilter.toutes ? 'Aucune note pour le moment' : 'Aucune note dans ce filtre',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
