class PrediccionDesnutricion {
  final int nivelDesnutricion;
  final String descripcion;
  final String recomendacion;

  PrediccionDesnutricion({
    required this.nivelDesnutricion,
    required this.descripcion,
    required this.recomendacion,
  });

  factory PrediccionDesnutricion.fromJson(Map<String, dynamic> json) {
    return PrediccionDesnutricion(
      nivelDesnutricion: json['nivel_desnutricion'],
      descripcion: json['descripcion'],
      recomendacion: json['recomendacion'],
    );
  }
}
