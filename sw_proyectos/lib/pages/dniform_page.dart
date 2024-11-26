import 'package:flutter/material.dart';
import '../repositories/usuario_respository.dart';
import 'result_page.dart';
import 'formDatos_page.dart';

class DNIFormPage extends StatelessWidget {
  final TextEditingController dniController = TextEditingController();
  final UsuarioRepository usuarioRepository = UsuarioRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verificar Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dniController,
              decoration: InputDecoration(labelText: 'DNI'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final mensaje = await usuarioRepository.verificarUsuario(dniController.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  InfanteFormPage(dniUsuario: "12345678")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
