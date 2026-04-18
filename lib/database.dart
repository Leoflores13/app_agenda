import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agenda.db');
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
      CREATE TABLE agendamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        procedimento TEXT,
        valor REAL,
        data TEXT,
        hora TEXT
      )
    ''');
  }

  Future<int> inserir(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('agendamentos', row);
  }

  Future<List<Map<String, dynamic>>> listar() async {
    final db = await instance.database;
    return await db.query('agendamentos');
  }
  Future<bool> horarioExiste(String data, String hora) async {
    final db = await instance.database;

    final result = await db.query(
      'agendamentos',
      where: 'data = ? AND hora = ?',
      whereArgs: [data, hora],
    );

    return result.isNotEmpty;
  }
  Future<double> totalPorDia(String data) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      "SELECT SUM(CAST(valor AS REAL)) as total FROM agendamentos WHERE data = ?",
      [data],
    );

    return result.first["total"] == null
        ? 0.0
        : (result.first["total"] as num).toDouble();
  }

  Future<double> totalPorMes(String mes) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      "SELECT SUM(CAST(valor AS REAL)) as total FROM agendamentos WHERE data LIKE ?",
      ["$mes%"],
    );

    return result.first["total"] == null
        ? 0.0
        : (result.first["total"] as num).toDouble();
  }
}