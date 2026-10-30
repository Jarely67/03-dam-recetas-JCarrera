import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/services/recipe_service.dart';
import 'package:recetas_app/widgets/receta_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Receta>> _recetas;

  @override
  void initState() {
    super.initState();
    _recetas = RecipeService().obtenerRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetas del Mayab')),
      body: FutureBuilder<List<Receta>>(
        future: _recetas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recetas = snapshot.data!;
          return ListView.builder(
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              return RecetaCard(receta: recetas[index]);
            },
          );
        },
      ),
    );
  }
}