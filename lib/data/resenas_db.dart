import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/resena.dart';

class ResenasDb {
  ResenasDb._();
  static final ResenasDb instancia = ResenasDb._();

  static const _nombreArchivo = 'resenas.db';
  static const _tabla = 'resenas';
  Database? _db;

  // Devuelve la BD abierta (la abre solo la primera vez)
  Future<Database> get _database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tabla(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receta_id INTEGER NOT NULL,
            autor TEXT NOT NULL,
            comentario TEXT NOT NULL,
            calificacion INTEGER NOT NULL,
            fecha TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Guarda una reseña y devuelve el id
  Future<int> insertar(Resena resena) async {
    final db = await _database;
    return db.insert(_tabla, resena.toMap());
  }

  // Lee las reseñas de una receta, la más reciente primero
  Future<List<Resena>> obtenerPorReceta(int recetaId) async {
    final db = await _database;
    final filas = await db.query(
      _tabla,
      where: 'receta_id = ?',
      whereArgs: [recetaId],
      orderBy: 'id DESC',
    );
    return filas.map(Resena.fromMap).toList();
  }

  // Modifica una reseña usando su id
  Future<int> actualizar(Resena resena) async {
    final db = await _database;
    return db.update(
      _tabla,
      resena.toMap(),
      where: 'id = ?',
      whereArgs: [resena.id],
    );
  }

  // Elimina una reseña con su id
  Future<int> eliminar(int id) async {
    final db = await _database;
    return db.delete(_tabla, where: 'id = ?', whereArgs: [id]);
  }
}