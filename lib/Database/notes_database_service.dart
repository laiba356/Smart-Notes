import 'package:sqflite/sql.dart';
import '../commomwidgets/note_model_class.dart';
import 'db_helper.dart';

class NotesDbService {
  final db = Db();

  Future<bool> insert(Notes notes) async {
    var db = await Db().database;
    int rowId = await db.insert(Notes.tableName, notes.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return rowId > -1;
  }

  Future<bool> update(Notes notes) async {
    var db = await Db().database;
    int rowId = await db.update(Notes.tableName, notes.toMap(),
        where: '${Notes.colTitle} = ?',
        whereArgs: [notes.title],
        conflictAlgorithm: ConflictAlgorithm.replace);
    return rowId > -1;
  }

  Future<bool> delete(Notes notes) async {
    var db = await Db().database;
    int rowId = await db.delete(
      Notes.tableName,
      where: '${Notes.colTitle} = ?',
      whereArgs: [notes.title],
    );
    return rowId > -1;
  }

  Future<bool> deleteAllNotes() async {
    var db = await Db().database;
    int rowId = await db.delete(Notes.tableName);
    return rowId > 0;
  }

  Future<List<Notes>> fetch() async {
    var db = await Db().database;
    var notesMaps = await db.query(Notes.tableName);
    // print("Fetched Data from DB: $notesMaps");
    var list = notesMaps
        .map(
          (map) => Notes.fromMap(map),
        )
        .toList();
    // print("list: $list");
    return list;
  }
}
