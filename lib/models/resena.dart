class Resena {
  final int? id;
  final int recetaId;
  final String autor;
  final String comentario;
  final int calificacion; // 1 a 5
  final String fecha; // ISO 8601

  const Resena({
    this.id,
    required this.recetaId,
    required this.autor,
    required this.comentario,
    required this.calificacion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receta_id': recetaId,
      'autor': autor,
      'comentario': comentario,
      'calificacion': calificacion,
      'fecha': fecha,
    };
  }

  factory Resena.fromMap(Map<String, dynamic> map) {
    return Resena(
      id: map['id'] as int?,
      recetaId: map['receta_id'] as int,
      autor: map['autor'] as String,
      comentario: map['comentario'] as String,
      calificacion: map['calificacion'] as int,
      fecha: map['fecha'] as String,
    );
  }
}