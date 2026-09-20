class Note {
  final int? id;
  final String text;
  final String date; // format yyyy-MM-dd
  final bool important;
  final bool done;

  const Note({
    this.id,
    required this.text,
    required this.date,
    this.important = false,
    this.done = false,
  });

  Note copyWith({
    int? id,
    String? text,
    String? date,
    bool? important,
    bool? done,
  }) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      date: date ?? this.date,
      important: important ?? this.important,
      done: done ?? this.done,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date,
      'important': important ? 1 : 0,
      'done': done ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int?,
      text: map['text'] as String,
      date: map['date'] as String,
      important: (map['important'] as int) == 1,
      done: (map['done'] as int) == 1,
    );
  }
}
