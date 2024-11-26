import '../models/infante_model.dart';
import '../services/api_service.dart';

class InfanteRepository {
  final ApiService apiService = ApiService();

  Future<String> insertarInfante(InfanteModel infante) {
    return apiService.insertarInfante(infante);
  }

  Future<Map<String, dynamic>> predecirNivelAnemia(InfanteModel infante) {
    return apiService.predecirNivelAnemia(infante);
  }
}
