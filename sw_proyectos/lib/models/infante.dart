class Infante {
  final String nombres; // Cambia 'nombre' a 'nombres'
  final String sexo;
  final int edad;
  final double peso;
  final double talla;
  final double hemoglobina;

  Infante({
    required this.nombres, // Cambia 'nombre' a 'nombres'
    required this.sexo,
    required this.edad,
    required this.peso,
    required this.talla,
    required this.hemoglobina,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombres': nombres, // Cambia 'nombre' a 'nombres'
      'sexo': sexo,
      'edad': edad,
      'peso': peso,
      'talla': talla,
      'hemoglobina': hemoglobina,
    };
  }
}
