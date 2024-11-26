class InfanteModel {
  final String dniUsuario;
  final String nombres;
  final String sexo;
  final String region;
  final int edad;
  final double peso;
  final double talla;
  final double hemoglobina;

  InfanteModel({
    required this.dniUsuario,
    required this.nombres,
    required this.sexo,
    required this.region,
    required this.edad,
    required this.peso,
    required this.talla,
    required this.hemoglobina,
  });

  Map<String, dynamic> toMap() {
    return {
      'dni_usuario': dniUsuario,
      'nombres': nombres,
      'sexo': sexo,
      'region': region,
      'edad': edad,
      'peso': peso,
      'talla': talla,
      'hemoglobina': hemoglobina,
    };
  }

  factory InfanteModel.fromMap(Map<String, dynamic> map) {
    return InfanteModel(
      dniUsuario: map['dni_usuario'],
      nombres: map['nombres'],
      sexo: map['sexo'],
      region: map['region'],
      edad: map['edad'],
      peso: map['peso'],
      talla: map['talla'],
      hemoglobina: map['hemoglobina'],
    );
  }
}
