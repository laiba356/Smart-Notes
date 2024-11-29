import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../commomwidgets/note_model_class.dart';

// class DB {
//   static const dbName = 'ELMS';
//   static const version = 1;
//   static DB? _instance;

//   DB._internal();
//   factory DB() {
//     return _instance ??= DB._internal();
//   }

//   Future<Database> get database async {
//     var dbPath = await getDatabasesPath();
//     return await openDatabase(
//       join(dbPath, dbName),
//       version: version,
//       singleInstance: true,
//       onCreate: (db, version) {
//         db.execute(Notes.createTable);
//       },
//     );
//   }
// }
class Db {
  static const dbName = "Notess";
  static const version = 1;
  static Db? _instance;
//to make sure only one object of db is created
  Db._internal();
  factory Db() {
    return _instance ??= Db._internal();
  }

  Future<Database> get database async {
    var path = await getDatabasesPath();

    return openDatabase(
      join(path, dbName),
      version: version,
      onCreate: (db, version) {
        db.execute(Notes.createTable);
      },
    );
  }
}
