import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Indicador de carga
import '../services/api_service.dart'; // Importa tu servicio

class ClusteringMapPage extends StatefulWidget {
  @override
  _ClusteringMapPageState createState() => _ClusteringMapPageState();
}

class _ClusteringMapPageState extends State<ClusteringMapPage> {
  final ApiService _apiService = ApiService();
  late final WebViewController _controller;
  String? _mapUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _fetchMapUrl();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Habilitar JavaScript
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            // Puedes bloquear navegación si es necesario
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _fetchMapUrl() async {
    try {
      final mapUrl = await _apiService.obtenerUrlMapaClustering();
      setState(() {
        _mapUrl = mapUrl;
      });
      _controller.loadRequest(Uri.parse('http://192.168.0.15:5000' +mapUrl));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Clustering'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          if (_mapUrl != null)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Text(
                'No se pudo cargar el mapa. Intenta nuevamente.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          if (_isLoading)
            Center(
              child: SpinKitFadingCircle(
                color: Colors.teal,
                size: 50.0,
              ),
            ),
        ],
      ),
    );
  }
}
