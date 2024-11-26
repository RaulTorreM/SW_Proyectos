import 'package:flutter/material.dart';

class ResultadosPage extends StatelessWidget {
  final String nombre;
  final String sexo;
  final int edad;
  final String region;
  final double peso;
  final double talla;
  final double hemoglobina;
  final int nivelAnemia;
  final String descripcion;
  final String recomendacion;

  const ResultadosPage({
    super.key,
    required this.nombre,
    required this.sexo,
    required this.edad,
    required this.peso,
    required this.region,
    required this.talla,
    required this.hemoglobina,
    required this.nivelAnemia,
    required this.descripcion,
    required this.recomendacion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultados de Diagnóstico"),
        backgroundColor: const Color(0xFF00796B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nivel de Anemia Destacado
            Container(
              width: double.infinity,  // Asegura que el Card ocupe todo el ancho
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.red[50],
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.bloodtype, size: 45, color: Colors.red[800]),
                      const SizedBox(height: 5),
                      Text(
                            "Nivel de Anemia",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.red[800],
                                ),
                          ),
                      Row(
                        children: [               
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              descripcion,
                              style: const TextStyle(fontSize: 20, height: 2, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Datos del Infante
            Text(
              "Datos del Infante",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow("Nombre", nombre),
                  _buildInfoRow("Sexo", sexo == "M" ? "Masculino" : "Femenino"),
                  _buildInfoRow("Edad (meses)", "$edad"),
                  _buildInfoRow("Provincia", region),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detalles Médicos - Grid de una fila (adaptado)
            Text(
              "Detalles Médicos",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            // Aquí se coloca en una fila los 3 elementos (peso, talla, hemoglobina)
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: "Peso (kg)",
                    content: peso.toStringAsFixed(2),
                    backgroundColor: Colors.green[100]!,
                    icon: Icons.monitor_weight,
                  ),
                ),
                const SizedBox(width: 10), // Separación entre cards
                Expanded(
                  child: _buildCard(
                    title: "Talla (cm)",
                    content: talla.toStringAsFixed(2),
                    backgroundColor: Colors.orange[100]!,
                    icon: Icons.height,
                  ),
                ),
                const SizedBox(width: 10), // Separación entre cards
                Expanded(
                  child: _buildCard(
                    title: "Hemoglob.",
                    content: hemoglobina.toStringAsFixed(2),
                    backgroundColor: Colors.purple[100]!,
                    icon: Icons.medical_services,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recomendación
            Text(
              "Recomendación",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey[200],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  recomendacion,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Imagen decorativa
            Center(
              child: Image.asset(
                "assets/images/imagen_infante.jpg",
                height: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black54),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
