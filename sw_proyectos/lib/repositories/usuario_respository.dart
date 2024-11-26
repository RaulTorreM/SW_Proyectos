import '../services/api_service.dart';

class UsuarioRepository {
  final ApiService apiService = ApiService();

  Future<String> verificarUsuario(String dni) {
    return apiService.verificarUsuario(dni);
  }
}
