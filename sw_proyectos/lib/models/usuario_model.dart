class UsuarioModel {
  final String dni;

  UsuarioModel({required this.dni});

  Map<String, dynamic> toMap() {
    return {'dni_usuario': dni};
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(dni: map['dni_usuario']);
  }
}
