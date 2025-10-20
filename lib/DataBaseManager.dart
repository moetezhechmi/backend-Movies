import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseManager {

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await intialiserDB();
    return _db!;

  }

  Future<Database> intialiserDB() async {
    String dataBasePath = await getDatabasesPath();
    // localhost/nomdelabase de donne
    String path = join(dataBasePath,'notes.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db , int version ) async {
          await db.execute('CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
        }

    );

  }

  // ajout
  Future<int> insertNote(String name) async {
    final mydb = await db;
    return await mydb.insert('notes', {'name': name});
  }

  // delete
  Future<int> deleteNote(int id) async {
    final mydb = await db;
    return await mydb.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // affichage
  Future<List<Map<String, dynamic>>> getNotes() async {
    final mydb = await db;
    return await mydb.query('notes', orderBy: 'id DESC');
  }

  // key value
  // "id" : 1
  // "name" : "note 1"
}