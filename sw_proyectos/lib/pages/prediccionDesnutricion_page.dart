import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/infante_model.dart'; // Modelo de Infante
import '../models/prediccionDesnutricion_model.dart'; // Modelo de la predicción

class InfantesPage extends StatefulWidget {
  @override
  _InfantesPageState createState() => _InfantesPageState();
}

class _InfantesPageState extends State<InfantesPage> {
  late Future<List<InfanteModel>> _infantes;

  @override
  void initState() {
    super.initState();
    _infantes = _fetchInfantes();
  }

  // Función para obtener la lista de infantes desde la base de datos
  Future<List<InfanteModel>> _fetchInfantes() async {
    // Aquí pones la lógica para obtener los datos de los infantes, ya sea desde una base de datos local o remota
    final response = await http.get(Uri.parse('http://192.168.0.15:5000/api/infantes'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => InfanteModel.fromMap(item)).toList();
    } else {
      throw Exception('Error al cargar los infantes');
    }
  }

  // Función para obtener la predicción de desnutrición desde la API
  Future<PrediccionDesnutricion> _getPrediccionDesnutricion(InfanteModel infante) async {
    final url = Uri.parse('http://192.168.0.15:5000/api/predict-malnutrition');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'edad': infante.edad,
        'peso': infante.peso,
        'talla': infante.talla,
        'hemoglobina': infante.hemoglobina,
      }),
    );

    if (response.statusCode == 200) {
      return PrediccionDesnutricion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener la predicción de desnutrición');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infantes y Predicción de Desnutrición"),
      ),
      body: FutureBuilder<List<InfanteModel>>(
        future: _infantes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay datos de infantes'));
          } else {
            List<InfanteModel> infantes = snapshot.data!;

            return ListView.builder(
              itemCount: infantes.length,
              itemBuilder: (context, index) {
                InfanteModel infante = infantes[index];

                return FutureBuilder<PrediccionDesnutricion>(
                  future: _getPrediccionDesnutricion(infante),
                  builder: (context, prediccionSnapshot) {
                    if (prediccionSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(infante.nombres),
                        subtitle: Text('Cargando predicción...'),
                      );
                    } else if (prediccionSnapshot.hasError) {
                      return ListTile(
                        title: Text(infante.nombres),
                        subtitle: Text('Error al obtener predicción'),
                      );
                    } else if (!prediccionSnapshot.hasData) {
                      return ListTile(
                        title: Text(infante.nombres),
                        subtitle: Text('No hay predicción disponible'),
                      );
                    } else {
                      PrediccionDesnutricion prediccion = prediccionSnapshot.data!;

                      return ListTile(
                        title: Text(infante.nombres),
                        subtitle: Text('Nivel de desnutrición: ${prediccion.nivelDesnutricion}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Aquí puedes agregar una acción al tap, como navegar a otra pantalla con más detalles
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
