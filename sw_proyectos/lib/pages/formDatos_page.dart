import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/infante_model.dart';
import '../repositories/infante_repository.dart';
import '../pages/resultados_page.dart';

class InfanteFormPage extends StatefulWidget {

  final String dniUsuario;

  const InfanteFormPage({super.key, required this.dniUsuario});

  @override
  _InfanteFormPageState createState() => _InfanteFormPageState();

  
}

class DecimalTextInputFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue, TextEditingValue newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) return TextEditingValue(text: '0.00');

      final num = double.parse(text) / 100;
      return TextEditingValue(
        text: num.toStringAsFixed(2),
        selection: TextSelection.collapsed(offset: num.toStringAsFixed(2).length),
      );
    }
  }


class _InfanteFormPageState extends State<InfanteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dniController;
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _hemoglobinaController = TextEditingController();

  String? _sexoSeleccionado;

   @override
    void initState() {
      super.initState();
      _dniController = TextEditingController(text: widget.dniUsuario);
    }
  

  // Lista de opciones para sexo
  final List<String> _sexoOpciones = ['M', 'F'];

  // Lista de regiones
  final List<String> _regiones = [
    'Junín',
    'Yauli',
    'Tarma',
    'Chanchamayo',
    'Satipo',
    'Jauja',
    'Concepción',
    'Huancayo',
    'Chupaca'
  ];

  Future<void> _submitForm() async {

        if (_formKey.currentState!.validate()) {
      final infante = InfanteModel(
        dniUsuario: _dniController.text,
        nombres: _nombresController.text,
        sexo: _sexoSeleccionado!,
        region: _regionController.text,
        edad: int.parse(_edadController.text),
        peso: double.parse(_pesoController.text),
        talla: double.parse(_tallaController.text),
        hemoglobina: double.parse(_hemoglobinaController.text),
      );

      try {
        // Predicción
        final resultado = await InfanteRepository().predecirNivelAnemia(infante);

        
        // Asegúrate de que el resultado no sea null
        final nivelAnemia = resultado['nivel_anemia'] ?? 0;
        final descripcion = resultado['descripcion'] ?? 'Descripción no disponible';
        final recomendacion = resultado['recomendacion'] ?? 'Recomendación no disponible';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultadosPage(
              nombre: infante.nombres,
              sexo: infante.sexo,
              edad: infante.edad,
              peso: infante.peso,
              region: infante.region,
              talla: infante.talla,
              hemoglobina: infante.hemoglobina,
              nivelAnemia: nivelAnemia,
              descripcion: descripcion,
              recomendacion: recomendacion,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formulario de Infante"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Datos del Infante",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dniController,
                  readOnly: true, // Bloquea el campo DNI
                  decoration: InputDecoration(
                    labelText: "DNI del Usuario",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Nombres
                TextFormField(
                  controller: _nombresController,
                  decoration: InputDecoration(
                    labelText: "Nombres",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Los nombres son requeridos";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Sexo
                DropdownButtonFormField<String>(
                  value: _sexoSeleccionado,
                  items: _sexoOpciones.map((sexo) {
                    return DropdownMenuItem(
                      value: sexo,
                      child: Text(sexo),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Sexo",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _sexoSeleccionado = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Seleccione un sexo" : null,
                ),
                SizedBox(height: 16),
                // Región
                DropdownButtonFormField<String>(
                  value: _regionController.text.isEmpty
                      ? null
                      : _regionController.text,
                  items: _regiones.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Provincia",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _regionController.text = value!;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Seleccione una región" : null,
                ),
                SizedBox(height: 16),
                // Edad
                TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Edad (en meses) [0-59]",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La edad es requerida";
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue < 0 || intValue > 59) {
                    return "La edad debe estar entre 0 y 59 meses";
                  }
                  return null;
                },
              ),

                SizedBox(height: 16),
                // Peso
                TextFormField(
                  controller: _pesoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter()],
                  decoration: InputDecoration(
                    labelText: "Peso (kg) [1.5 - 50.0]",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El peso es requerido";
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue < 1.5 || doubleValue > 50.0) {
                      return "El peso debe estar entre 1.5 y 50.0 kg";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),
                // Talla
                TextFormField(
                  controller: _tallaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter()],
                  decoration: InputDecoration(
                    labelText: "Talla (cm) [40.0 - 150.0cm]",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La talla es requerido";
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue < 40.0 || doubleValue > 150.0) {
                      return "El talla debe estar entre 40.0 y 150.0 cm";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Hemoglobina
                TextFormField(
                  controller: _hemoglobinaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter()],
                  decoration: InputDecoration(
                    labelText: "Hemoglobina (g/dL) [4.5 - 17.5 g/dL]",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El nivel de Hemoglobina es requerido";
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue < 4.5 || doubleValue > 17.5) {
                      return "El nivel de Hemoglobina debe estar entre 4.5 y 17.5 g/dL";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Botón de envío
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text("Enviar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
}
