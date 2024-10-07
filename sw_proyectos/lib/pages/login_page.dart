import 'package:flutter/material.dart';
import 'formDatos_page.dart';
import 'anemiaTest_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final dniController = TextEditingController(); // Controlador para el DNI

  Future<void> verificarDNI(BuildContext context) async {
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
        // Si el DNI ya está registrado o se creó correctamente, navegar a formDatos_page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormPage(dni: dniController.text), // Pasar el DNI
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black, // Color de fondo oscuro
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.black], // Gradiente oscuro
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 70, 0, 32),
                  child: Container(
                    width: 200,
                    height: 70,
                    alignment: Alignment.center,
                    child: Text(
                      'Food-Health',
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '¿Preocupado por la salud de tu hijo(a)?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB4AFAF),
                      fontSize: 25,
                      fontFamily: 'Inter Tight',
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                  child: Text(
                    'Ingresa el DNI del apoderado para iniciar el test de anemia y/o desnutrición crónica',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 570),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: dniController,
                            decoration: InputDecoration(
                              labelText: 'Número de DNI',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              verificarDNI(context); // Verificar el DNI
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Verificar DNI',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}