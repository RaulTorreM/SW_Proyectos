import 'package:flutter/material.dart';
import 'dniform_page.dart';
import 'mapaClustering_page.dart'; 
import 'prediccionDesnutricion_page.dart';
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DNIFormPage()),
                );
              },
              child: Text('Ingresar DNI'),
            ),
            SizedBox(height: 20), // Espaciado entre los botones
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClusteringMapPage()),
                );
              },
              child: Text('Ver Mapa de Clustering'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfantesPage()),
                );
              },
              child: Text('Ver Predicciones de Desnutrición'),
            ),
          ],
        ),
      ),
    );
  }
}
