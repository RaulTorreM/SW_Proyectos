import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnemiaPredictor extends StatefulWidget {
  @override
  _AnemiaPredictorState createState() => _AnemiaPredictorState();
}

class _AnemiaPredictorState extends State<AnemiaPredictor> {
  final _formKey = GlobalKey<FormState>();
  final dniController = TextEditingController();
  final edadController = TextEditingController();
  final pesoController = TextEditingController();
  final tallaController = TextEditingController();
  final hemoglobinaController = TextEditingController();

  bool _isInfanteFormVisible = false;
  String? _prediccion; // Para almacenar la predicción

  Future<void> verificarDNI() async {
    if (dniController.text.length != 8) {
      // Validar longitud del DNI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El DNI debe tener 8 caracteres.')),
      );
      return;
    }

    // Verificar el DNI usando la API
    final response = await http.post(
      Uri.parse('http://192.168.0.15/Datos_proyecto/verificar_dni.php'), // Cambia esta URL si es necesario
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'DNI_Usuario': dniController.text}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        // Si el DNI ya está registrado o se creó correctamente
        setState(() {
          _isInfanteFormVisible = true; // Mostrar el formulario del infante
        });
      } else {
        // Mostrar mensaje de error si el DNI no se pudo crear
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      throw Exception('Error al verificar el DNI');
    }
  }

  Future<void> enviarDatos() async {
    try {
      // Enviar datos del infante
      final response = await http.post(
        Uri.parse('http://192.168.0.15/Datos_proyecto/agregar_datos.php'), // Cambia esta URL si es necesario
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'DNI_Usuario': dniController.text,
          'nombres': 'Nombre del Infante', // Cambia esto según tu lógica
          'sexo': 'M', // Cambia esto según tu lógica
          'edad': int.parse(edadController.text),
          'peso': double.parse(pesoController.text),
          'talla': double.parse(tallaController.text),
          'hemoglobina': double.parse(hemoglobinaController.text),
        }),
      );

      if (response.statusCode == 200) {
        // Obtener la predicción
        int prediccion = await obtenerPrediccion(
          int.parse(edadController.text),
          double.parse(pesoController.text),
          double.parse(tallaController.text),
          double.parse(hemoglobinaController.text),
        );

        // Guardar el diagnóstico en la base de datos
        await guardarDiagnostico(prediccion);

        setState(() {
          _prediccion = prediccion.toString(); // Almacenar la predicción
        });

        // Limpiar los campos
        edadController.clear();
        pesoController.clear();
        tallaController.clear();
        hemoglobinaController.clear();
      } else {
        // Manejar el error de respuesta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar datos: ${response.body}')),
        );
      }
    } catch (e) {
      // Manejar excepciones
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }

  Future<int> obtenerPrediccion(int edad, double peso, double talla, double hemoglobina) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/predict'), // Enlace al servidor Flask
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
      return data['prediccion'];
    } else {
      throw Exception('Error al predecir');
    }
  }

  Future<void> guardarDiagnostico(int nivelAnemia) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.15/Datos_proyecto/guardar_diagnostico.php'), // Cambia esta URL si es necesario
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'DNI_Usuario': dniController.text,
        'nivel_anemia': nivelAnemia,
        'fecha_diagnostico': DateTime.now().toIso8601String().split('T')[0], // Fecha actual
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar el diagnóstico');
    }
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
            // Campo para ingresar el DNI del apoderado
            TextFormField(
              controller: dniController,
              decoration: InputDecoration(labelText: 'DNI del Apoderado'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: verificarDNI, // Cambiar a verificarDNI
              child: Text('Verificar DNI'),
            ),
            if (_isInfanteFormVisible) ...[
              // Formulario para ingresar los datos del infante
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
                          enviarDatos(); // Enviar datos a la API para agregar
                        }
                      },
                      child: Text('Enviar Datos y Predecir'),
                    ),
                    if (_prediccion != null) ...[
                      SizedBox(height: 20),
                      Text('Predicción de Anemia: $_prediccion'),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}