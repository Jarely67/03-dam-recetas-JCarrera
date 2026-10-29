import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recetas_app/models/receta.dart';

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Receta>> obtenerRecetas() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> lista = data['recipes'];
      return lista.map((item) => Receta.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar recetas: ${response.statusCode}');
    }
  }
}