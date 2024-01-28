import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE your_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT,
            date TEXT,
            title TEXT,
            hour TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertData(String content, String date,String title,String hour) async {
    Database db = await database;
    await db.insert('your_table', {'content': content, 'date': date,'title':title,'hour':hour},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDataByDate(String date) async {
    Database db = await database;
    return await db.query('your_table',
        where: 'date = ?', whereArgs: [date]);
  }
  

   Future<void> deleteNoteByDateAndContent(String date, String content) async {
    Database db = await database;
    await db.delete(
      'your_table',
      where: 'date = ? AND content = ?',
      whereArgs: [date, content],
    );
  }
}
