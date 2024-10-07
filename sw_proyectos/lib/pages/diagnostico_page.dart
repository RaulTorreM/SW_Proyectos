import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiagnosticoPage extends StatefulWidget {
  final String nombre;
  final String sexo;
  final int edad;
  final double peso;
  final double talla;
  final double hemoglobina;
  final int nivelAnemia;

  const DiagnosticoPage({
    Key? key,
    required this.nombre,
    required this.sexo,
    required this.edad,
    required this.peso,
    required this.talla,
    required this.hemoglobina,
    required this.nivelAnemia,
  }) : super(key: key);

  @override
  _DiagnosticoPageState createState() => _DiagnosticoPageState();
}

class _DiagnosticoPageState extends State<DiagnosticoPage> {
  String? descripcion;
  String? recomendacion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerDatosNivelAnemia();
  }

  Future<void> obtenerDatosNivelAnemia() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.15/Datos_proyecto/obtener_nivel_anemia.php?nivel_anemia=${widget.nivelAnemia}'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          descripcion = data['descripcion'] ?? 'No disponible';
          recomendacion = data['recomendacion'] ?? 'No disponible';
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnóstico', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 39, 18, 71),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Acción de volver
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Acción del botón "Salir"
              },
              child: Text(
                'Salir',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnóstico: ${descripcion ?? "Nivel Desconocido"}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 138, 93, 26)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.nombre,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      '${widget.sexo == "M" ? "Masculino" : "Femenino"}, ${widget.edad} años',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Recomendaciones',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      recomendacion ?? 'No disponible',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Datos Importantes',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDataCard('Peso (kg)', widget.peso.toString()),
                        _buildDataCard('Talla (m)', widget.talla.toString()),
                        _buildDataCard('Hemoglobina (g/dL)', widget.hemoglobina.toString()),
                      ],
                    ),
                    SizedBox(height: 30), // Espacio entre las tarjetas y la imagen
                    Center(
                      child: Image.network(
                        'https://img.lovepik.com/element/40173/6465.png_860.png',
                        height: 250, // Aumentar el tamaño de la imagen
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDataCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 184, 182, 182), // Color oscuro para las tarjetas
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}