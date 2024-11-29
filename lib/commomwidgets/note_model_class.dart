import 'dart:convert';

class Notes {
  String? title;
  String? note;
  String? dateTime;

  static const tableName = 'Notes';
  static const colTitle = 'Title';
  static const colNote = 'Note';
  static const colDateTime = 'DateTime';

  static const createTable = '''
  CREATE TABLE $tableName (
    $colTitle TEXT PRIMARY KEY, 
    $colNote TEXT, 
    $colDateTime TEXT
  )
  ''';

  Notes({
    this.title,
    this.note,
    this.dateTime,
  });

  Notes copyWith({
    String? title,
    String? note,
    String? dateTime,
  }) {
    return Notes(
      title: title ?? this.title,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Note': note,
      'DateTime': dateTime,
    };
  }

  factory Notes.fromMap(Map<String, dynamic> map) {
    return Notes(
      title: map['Title'] as String,
      note: map['Note'] as String,
      dateTime: map['DateTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Notes.fromJson(String source) =>
      Notes.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NoteModel(Title: $title, Note: $note, DateTime: $dateTime)';
  }

  @override
  bool operator ==(covariant Notes other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.note == note &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return title.hashCode ^ note.hashCode ^ dateTime.hashCode;
  }
}
