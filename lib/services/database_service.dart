import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/registro_forestal.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('registros_forestales.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros_forestales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numeroSitio TEXT NOT NULL,
        numeroArbol TEXT NOT NULL,
        especieNombreComun TEXT NOT NULL,
        diametroTocon REAL,
        diametroNormal REAL NOT NULL,
        alturaTotal REAL NOT NULL,
        diametroCopa REAL,
        dano TEXT,
        vigorosidad TEXT,
        areaBasal REAL NOT NULL,
        volumenCilindro REAL NOT NULL,
        fechaRegistro TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertarRegistro(RegistroForestal registro) async {
    final db = await database;
    return await db.insert('registros_forestales', registro.toMap());
  }

  Future<List<RegistroForestal>> obtenerTodosLosRegistros() async {
    final db = await database;
    final result = await db.query('registros_forestales', orderBy: 'fechaRegistro DESC');
    return result.map((map) => RegistroForestal.fromMap(map)).toList();
  }

  Future<int> contarRegistros() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM registros_forestales');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> eliminarRegistro(int id) async {
    final db = await database;
    return await db.delete(
      'registros_forestales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}