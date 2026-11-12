import 'package:flutter/material.dart';
import 'package:recetas_app/data/resenas_db.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/models/resena.dart';
import 'package:recetas_app/screens/formulario_resena_screen.dart';

class ResenasScreen extends StatefulWidget {
  final Receta receta;

  const ResenasScreen({super.key, required this.receta});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  late Future<List<Resena>> _futureResenas;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futureResenas = ResenasDb.instancia.obtenerPorReceta(widget.receta.id);
  }

  Future<void> _abrirFormulario([Resena? resena]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioResenaScreen(
          recetaId: widget.receta.id,
          resena: resena,
        ),
      ),
    );
    if (guardado == true) {
      setState(_cargar); // recarga la lista
    }
  }

  Future<void> _eliminar(Resena resena) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Seguro que quieres eliminar esta reseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await ResenasDb.instancia.eliminar(resena.id!);
      if (!mounted) return;
      setState(_cargar);
    }
  }

  String _formatearFecha(String iso) {
    final f = DateTime.parse(iso);
    final dd = f.day.toString().padLeft(2, '0');
    final mm = f.month.toString().padLeft(2, '0');
    return '$dd/$mm/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas: ${widget.receta.nombre}'),
        backgroundColor: const Color.fromARGB(255, 80, 23, 3),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_comment),
        label: const Text('Agregar reseña'),
      ),
      body: FutureBuilder<List<Resena>>(
        future: _futureResenas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final resenas = snapshot.data!;
          if (resenas.isEmpty) {
            return const Center(
              child: Text('Aún no hay reseñas. ¡Sé el primero en comentar!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            itemCount: resenas.length,
            itemBuilder: (context, index) {
              final r = resenas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.autor,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _abrirFormulario(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminar(r),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < r.calificacion
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatearFecha(r.fecha),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(r.comentario),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}