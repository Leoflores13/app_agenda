import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 🔌 CONECTAR AO BANCO
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

  // 🧱 CRIAR TABELA
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE agendamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        procedimento TEXT,
        valor TEXT,
        data TEXT,
        hora TEXT
      )
    ''');
  }

  // ➕ INSERIR
  Future<int> inserir(Map<String, dynamic> dados) async {
    final db = await instance.database;
    return await db.insert('agendamentos', dados);
  }

  // 📋 LISTAR
  Future<List<Map<String, dynamic>>> listar() async {
    final db = await instance.database;
    return await db.query('agendamentos');
  }

  // 🔍 VERIFICAR HORÁRIO DUPLICADO
  Future<bool> horarioExiste(String data, String hora) async {
    final db = await instance.database;

    final result = await db.query(
      'agendamentos',
      where: 'data = ? AND hora = ?',
      whereArgs: [data, hora],
    );

    return result.isNotEmpty;
  }

  // 🗑️ EXCLUIR
  Future<int> excluir(int id) async {
    final db = await instance.database;
    return await db.delete(
      'agendamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✏️ ATUALIZAR
  Future<int> atualizar(Map<String, dynamic> dados) async {
    final db = await instance.database;

    return await db.update(
      'agendamentos',
      dados,
      where: 'id = ?',
      whereArgs: [dados['id']],
    );
  }

  // ❌ FECHAR BANCO
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}