import 'package:flutter/material.dart';
import 'package:recetas_app/data/resenas_db.dart';
import 'package:recetas_app/models/resena.dart';

class FormularioResenaScreen extends StatefulWidget {
  final int recetaId;
  final Resena? resena; // null = nueva, con valor = editar

  const FormularioResenaScreen({super.key, required this.recetaId, this.resena});

  @override
  State<FormularioResenaScreen> createState() => _FormularioResenaScreenState();
}

class _FormularioResenaScreenState extends State<FormularioResenaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _autorCtrl;
  late final TextEditingController _comentarioCtrl;
  late int _calificacion;
  bool _guardando = false;

  bool get _esEdicion => widget.resena != null;

  @override
  void initState() {
    super.initState();
    _autorCtrl = TextEditingController(text: widget.resena?.autor ?? '');
    _comentarioCtrl =
        TextEditingController(text: widget.resena?.comentario ?? '');
    _calificacion = widget.resena?.calificacion ?? 5;
  }

  @override
  void dispose() {
    _autorCtrl.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final resena = Resena(
      id: widget.resena?.id,
      recetaId: widget.recetaId,
      autor: _autorCtrl.text.trim(),
      comentario: _comentarioCtrl.text.trim(),
      calificacion: _calificacion,
      fecha: widget.resena?.fecha ?? DateTime.now().toIso8601String(),
    );

    if (_esEdicion) {
      await ResenasDb.instancia.actualizar(resena);
    } else {
      await ResenasDb.instancia.insertar(resena);
    }
    if (!mounted) return;
    Navigator.pop(context, true); // avisa que se guardó algo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar reseña' : 'Nueva reseña'),
        backgroundColor: const Color.fromARGB(255, 80, 23, 3),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _autorCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Calificación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (i) {
                final valor = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _calificacion = valor),
                  icon: Icon(
                    valor <= _calificacion ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 34,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _comentarioCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Comentario',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.comment),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Escribe al menos 5 caracteres'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Publicar reseña'),
            ),
          ],
        ),
      ),
    );
  }
}