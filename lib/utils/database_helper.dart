import 'dart:async';
import 'dart:io';
import 'package:flutter_note_app/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper
  static Database _database;
  String databaseName = 'notes.db';
  int databaseVersion = 1;
  String noteTable = "note_table";
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); //
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '$databaseName';
    var noteDatabase =
        await openDatabase(path, version: databaseVersion, onCreate: _createDb);
    return noteDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Get all notes
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database database = await this.database;
    //var result = await database.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await database.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert note
  Future<int> insertNote(Note note) async {
    Database database = await this.database;
    var result = await database.insert(noteTable, note.toMap());
    return result;
  }

  // Update Note
  Future<int> updateNote(Note note) async {
    var database = await this.database;
    var result = await database.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Note
  Future<int> deleteNote(int id) async {
    var database = await this.database;
    int result =
        await database.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  // Get number of Notes
  Future<int> getCount() async {
    Database database = await this.database;
    List<Map<String, dynamic>> x =
        await database.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}
