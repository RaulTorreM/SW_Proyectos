import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predicción de Anemia Infantil',
      home: AnemiaPredictor(),
    );
  }
}

class AnemiaPredictor extends StatefulWidget {
  @override
  _AnemiaPredictorState createState() => _AnemiaPredictorState();
}

class _AnemiaPredictorState extends State<AnemiaPredictor> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final edadController = TextEditingController();
  final pesoController = TextEditingController();
  final tallaController = TextEditingController();
  final hemoglobinaController = TextEditingController();

  List _data = [];
  List _predicciones = [];

  Future<void> enviarDatos() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.15/Datos_proyecto/agregar_niños.php'),  // Cambia esta URL si es necesario
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'edad': int.parse(edadController.text),         // Asegúrate de que los controladores no estén vacíos
        'peso': double.parse(pesoController.text),       // Asegúrate de que los controladores no estén vacíos
        'talla': double.parse(tallaController.text),     // Asegúrate de que los controladores no estén vacíos
        'hemoglobina': double.parse(hemoglobinaController.text), // Asegúrate de que los controladores no estén vacíos
      }),
    );

    if (response.statusCode == 200) {
      // Una vez que los datos se han enviado correctamente, actualizar la lista
      obtenerDatos();
      // Limpiar los campos
      edadController.clear();
      pesoController.clear();
      tallaController.clear();
      hemoglobinaController.clear();
    } else {
      throw Exception('Error al enviar datos');
    }
}


  // Función para obtener datos desde la base de datos
  Future<void> obtenerDatos() async {
    final response = await http.get(Uri.parse('http://192.168.0.15/Datos_proyecto/get_niños.php'));

    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body);
      });

      // Obtener la predicción para cada niño
      for (var item in _data) {
        // Asegúrate de que estás usando los tipos correctos
        int edad = int.parse(item['edad'].toString());
        double peso = double.parse(item['peso'].toString());
        double talla = double.parse(item['talla'].toString());
        double hemoglobina = double.parse(item['hemoglobina'].toString());

        int prediccion = await obtenerPrediccion(edad, peso, talla, hemoglobina);
        setState(() {
          _predicciones.add(prediccion);  // Guardar la predicción en la lista
        });
      }
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  // Función para hacer la predicción desde la API Flask
  Future<int> obtenerPrediccion(int edad, double peso, double talla, double hemoglobina) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/predict'),  // Enlace al servidor Flask
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'edad': edad,
        'peso': peso,
        'talla': talla,
        'hemoglobina': hemoglobina,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['prediccion'];  // Aquí obtienes la predicción
    } else {
      throw Exception('Error al predecir');
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerDatos();  // Cargar los datos al iniciar
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predicción de Anemia Infantil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: edadController,
                    decoration: InputDecoration(labelText: 'Edad (meses)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la edad';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: pesoController,
                    decoration: InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el peso';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: tallaController,
                    decoration: InputDecoration(labelText: 'Talla (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la talla';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: hemoglobinaController,
                    decoration: InputDecoration(labelText: 'Hemoglobina (g/dL)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la hemoglobina';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        enviarDatos();  // Enviar datos a la API para agregar
                        obtenerDatos();
                      }
                    },
                    child: Text('Enviar Datos y Predecir'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Datos Registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Niño ${_data[index]['id']}'),
                    subtitle: Text(
                        'Edad: ${_data[index]['edad']} meses, Peso: ${_data[index]['peso']} kg, '
                        'Talla: ${_data[index]['talla']} cm, Hemoglobina: ${_data[index]['hemoglobina']} g/dL'),
                    trailing: Text(
                      'Predicción: ${_predicciones.length > index ? _predicciones[index].toString() : "Cargando..."}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
