import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<Map<String, dynamic>> _ranking = []; // Lista para almacenar el ranking de regiones
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRankingData(); // Cargar los datos al iniciar la página
  }

  Future<void> fetchRankingData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.15/Datos_proyecto/ranking_regiones.php'));
      if (response.statusCode == 200) {
        setState(() {
          _ranking = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking de Regiones con Más Casos de Anemia'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carga
          : _ranking.isEmpty
              ? Center(child: Text('No se encontraron datos'))
              : ListView.builder(
                  itemCount: _ranking.length,
                  itemBuilder: (context, index) {
                    final regionData = _ranking[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'), // Muestra la posición en el ranking
                      ),
                      title: Text(regionData['region']),
                      trailing: Text(
                        'Casos: ${regionData['casos_anemia']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
    );
  }
}
