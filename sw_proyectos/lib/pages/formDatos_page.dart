import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'diagnostico_page.dart';
import '../models/infante.dart'; // Importar el modelo

class FormPage extends StatefulWidget {
  final String dni; // Recibir el DNI del apoderado

  const FormPage({Key? key, required this.dni}) : super(key: key); // Constructor que recibe el DNI

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final nombreController = TextEditingController();
  final edadController = TextEditingController();
  final pesoController = TextEditingController();
  final tallaController = TextEditingController();
  final hemoglobinaController = TextEditingController();
  String? _sexo; // Para almacenar el sexo del infante
  String? _prediccion; // Para almacenar la predicción
  String? _region; // Para almacenar la región seleccionada

  // Lista de regiones disponibles
  final List<String> _regiones = [
    'Amazonas', 'Áncash', 'Apurímac', 'Arequipa', 'Ayacucho', 'Cajamarca',
    'Cusco', 'Huancavelica', 'Huánuco', 'Ica', 'Junín', 'La Libertad',
    'Lambayeque', 'Lima', 'Loreto', 'Madre de Dios', 'Moquegua', 'Pasco',
    'Piura', 'Puno', 'San Martín', 'Tacna', 'Tumbes', 'Ucayali'
  ];

  Future<void> enviarDatos() async {
    if (_formKey.currentState!.validate()) {
      if (_sexo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona el sexo')),
        );
        return;
      }
      if (_region == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona la región')),
        );
        return;
      }

      // Crear una instancia del modelo Infante
      Infante infante = Infante(
        nombres: nombreController.text,
        sexo: _sexo!,
        edad: int.parse(edadController.text),
        peso: double.parse(pesoController.text),
        talla: double.parse(tallaController.text),
        hemoglobina: double.parse(hemoglobinaController.text),
      );

      try {
        // Crear el cuerpo de la solicitud incluyendo la región
        var requestBody = {
          'DNI_Usuario': widget.dni,
          'region': _region, // Añadir la región al cuerpo de la solicitud
          ...infante.toJson(),
        };
        print('Datos a enviar: ${jsonEncode(requestBody)}');

        // Enviar datos del infante a la API
        final response = await http.post(
          Uri.parse('http://192.168.0.15/Datos_proyecto/agregar_datos.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['success']) {
            int prediccion = await obtenerPrediccion(infante);
            await guardarDiagnostico(prediccion, infante);

            setState(() {
              _prediccion = prediccion.toString();
            });

            // Navegar a DiagnosticoPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiagnosticoPage(
                  nombre: infante.nombres,
                  sexo: infante.sexo,
                  edad: infante.edad,
                  peso: infante.peso,
                  talla: infante.talla,
                  hemoglobina: infante.hemoglobina,
                  nivelAnemia: prediccion,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar datos: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error: $e')),
        );
      }
    }
  }

    Future<int> obtenerPrediccion(Infante infante) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(infante.toJson()),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['prediccion'];
    } else {
      throw Exception('Error al predecir');
    }
  }

  Future<void> guardarDiagnostico(int nivelAnemia, Infante infante) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.15/Datos_proyecto/guardar_diagnostico.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'DNI_Usuario': widget.dni,
        'nombres': infante.nombres,
        'sexo': infante.sexo,
        'talla': infante.talla,
        'peso': infante.peso,
        'hemoglobina': infante.hemoglobina,
        'edad': infante.edad,
        'nivel_anemia': nivelAnemia,
        'fecha_diagnostico': DateTime.now().toIso8601String().split('T')[0],
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
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Ingresar Datos del hijo(a)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Infante*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: InputDecoration(
                  labelText: 'Sexo*',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                  DropdownMenuItem(value: 'F', child: Text('Femenino')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexo = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona el sexo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _region,
                decoration: InputDecoration(
                  labelText: 'Región*',
                  border: OutlineInputBorder(),
                ),
                items: _regiones.map((region) => DropdownMenuItem(
                  value: region,
                  child: Text(region),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _region = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona la región';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: edadController,
                decoration: InputDecoration(
                  labelText: 'Edad (meses)*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la edad';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: pesoController,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el peso';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: tallaController,
                decoration: InputDecoration(
                  labelText: 'Talla (cm)*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la talla';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: hemoglobinaController,
                decoration: InputDecoration(
                  labelText: 'Hemoglobina (g/dL)*',
                  border: OutlineInputBorder(),
                ),
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
                    enviarDatos(); // Enviar datos a la API
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Diagnosticar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              if (_prediccion != null) ...[
                SizedBox(height: 20),
                Text('Predicción de Anemia: $_prediccion'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
