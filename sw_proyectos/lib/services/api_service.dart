import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/infante_model.dart';
import '../models/usuario_model.dart';

class ApiService {
  final String baseUrl = 'http://192.168.0.15:5000/api'; // Cambia esto con tu URL

  // Verificar o crear usuario
  Future<String> verificarUsuario(String dniUsuario) async {
    final url = Uri.parse('$baseUrl/verificar_usuario');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'dni_usuario': dniUsuario}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['mensaje'];
    } else {
      throw Exception('Error al verificar usuario');
    }
  }

  // Insertar infante
  Future<String> insertarInfante(InfanteModel infante) async {
    final url = Uri.parse('$baseUrl/insert');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(infante.toMap()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['mensaje'];
    } else {
      throw Exception('Error al insertar infante');
    }
  }

  // Predecir nivel de anemia
  Future<Map<String, dynamic>> predecirNivelAnemia(InfanteModel infante) async {
    final url = Uri.parse('$baseUrl/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(infante.toMap()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Asegúrate de que los campos clave no sean null
      final nivelAnemia = data['nivel_anemia'];
      final descripcion = data['descripcion'] ?? 'Descripción no disponible';
      final recomendacion = data['recomendacion'] ?? 'Recomendación no disponible';

      // Puedes retornar un mapa con los datos relevantes
      return {
        'nivel_anemia': nivelAnemia,
        'descripcion': descripcion,
        'recomendacion': recomendacion,
      };
    } else {
      throw Exception("Error de red: ${response.statusCode}");
    }
  }

  // Obtener URL del mapa de clustering
  Future<String> obtenerUrlMapaClustering() async {
    final url = Uri.parse('$baseUrl/clustering-map');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['map_url'];  // Devuelve la URL
    } else {
      throw Exception('Failed to load map URL');
    }
  }


}
