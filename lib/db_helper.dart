import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> criarTabelas(sql.Database database) async {
    await database.execute("""CREATE TABLE listaDeTarefas(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
    titulo TEXT,
    descricao TEXT,
    dataDeRegistro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<sql.Database> db() async{
    return sql.openDatabase(
      "nome_do_banco.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await criarTabelas(database);
      });
  }

  static Future<int> adicionar(String titulo, String? descricao) async{
    final db = await SQLHelper.db();

    final dado = {'titulo' : titulo, 'descricao' : descricao};
    final id = await db.insert('listaDeTarefas', dado, conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> obterTodas() async {
    final db = await SQLHelper.db();
    return db.query('listaDeTarefas', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> obterPorId(int id) async {
    final db = await SQLHelper.db();
    return db.query('listaDeTarefas', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> editar(int id, String titulo, String? descricao) async {
    final db = await SQLHelper.db();
    final dado = {
      'titulo': titulo,
      'descricao': descricao,
      'dataDeRegistro': DateTime.now().toString()
    };
    final resultado =
    await db.update('listaDeTarefas', dado, where: "id = ?", whereArgs: [id]);
    return resultado;
  }

    static Future<void> deletar(int id) async {
      final db = await SQLHelper.db();
      try {
        await db.delete('listaDeTarefas', where: "id = ?", whereArgs: [id]);
      } catch (e) {}
  }
}