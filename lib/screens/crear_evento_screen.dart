import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class CrearEventoScreen extends StatefulWidget {
  const CrearEventoScreen({super.key});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController(); 
  final _precioCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  File? _imagenSeleccionada;
  double? _latitud = -15.4922; 
  double? _longitud = -70.1309; 
  bool _isSaving = false;
  
  String _nivelEducativoSeleccionado = 'Primaria'; 

  // Abre el calendario nativo adaptado al tema Dark/Morado
  Future<void> _seleccionarFechaCalendario(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.purpleAccent, // Encabezado morado neón
              onPrimary: Colors.black, 
              surface: Color(0xFF1E1E2C), // Fondo del calendario
              onSurface: Colors.white, 
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C), // Fondo oscuro
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purpleAccent),
                title: const Text('Elegir de la Galería', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.gallery); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.purpleAccent),
                title: const Text('Tomar Foto con Cámara', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.camera); 
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarImagen(ImageSource fuente) async {
    final picker = ImagePicker();
    final archivo = await picker.pickImage(source: fuente, imageQuality: 70);
    
    if (archivo != null) {
      setState(() {
        _imagenSeleccionada = File(archivo.path);
      });
    }
  }

  Future<void> _obtenerGPS() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitud = position.latitude;
      _longitud = position.longitude;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Ubicación GPS capturada con éxito! 📍'), 
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final url = Uri.parse("${Constants.baseUrl}/events");
      var request = http.MultipartRequest('POST', url);
      
      request.headers['Accept'] = 'application/json';
      
      request.fields['titulo'] = _tituloCtrl.text.trim();
      request.fields['descripcion'] = _descCtrl.text.trim();
      request.fields['fecha_hora'] = _fechaCtrl.text.trim();
      request.fields['precio_entrada'] = _precioCtrl.text.trim();
      request.fields['telefono_organizador'] = _telCtrl.text.trim();
      request.fields['latitud'] = _latitud.toString();
      request.fields['longitud'] = _longitud.toString();
      request.fields['nivel_educativo'] = _nivelEducativoSeleccionado;

      if (_imagenSeleccionada != null) {
        request.files.add(await http.MultipartFile.fromPath('imagen', _imagenSeleccionada!.path));
      }

      var response = await request.send();
      setState(() => _isSaving = false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Fiesta publicada con éxito! 🎉'), 
            backgroundColor: Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); 
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error HTTP: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error del Servidor (${response.statusCode}).'), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      print("Error Crítico HTTP: $e");
    }
  }

  // Estilo reutilizable para los campos de texto Dark/Purple
  InputDecoration _customInputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.purpleAccent),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E), // Fondo negro premium profundo
      appBar: AppBar(
        title: const Text(
          'Bienvenido al Gooooo', 
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)
        ), 
        backgroundColor: const Color(0xFF12121C), // Encabezado oscuro integrado
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _tituloCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: _customInputStyle('Nombre del Evento *', Icons.celebration),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: _customInputStyle('Descripción', Icons.description_outlined),
                  maxLines: 2
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _fechaCtrl,
                  readOnly: true, 
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Fecha del Evento *', 
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.purpleAccent), 
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                    ),
                  ),
                  onTap: () => _seleccionarFechaCalendario(context), 
                  validator: (v) => v!.isEmpty ? 'Por favor selecciona una fecha' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _precioCtrl, 
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _customInputStyle('Precio Entrada *', Icons.confirmation_number_outlined),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _telCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: _customInputStyle('WhatsApp del Organizador', Icons.phone_android),
                  keyboardType: TextInputType.phone
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Nivel Educativo *',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'Primaria', label: Text('Primaria'), icon: Icon(Icons.child_care)),
                      ButtonSegment<String>(value: 'Secundaria', label: Text('Secundaria'), icon: Icon(Icons.school)),
                      ButtonSegment<String>(value: 'Superior', label: Text('Superior'), icon: Icon(Icons.menu_book)),
                    ],
                    selected: <String>{_nivelEducativoSeleccionado},
                    onSelectionChanged: (Set<String> nuevaSeleccion) {
                      setState(() {
                        _nivelEducativoSeleccionado = nuevaSeleccion.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E2C),
                      foregroundColor: Colors.white70,
                      selectedBackgroundColor: Colors.purple,
                      selectedForegroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white12),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                // Sección de Foto Estilizada
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _mostrarOpcionesImagen, 
                        icon: const Icon(Icons.image), 
                        label: const Text('Agregar Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.withOpacity(0.3),
                          foregroundColor: Colors.purpleAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _imagenSeleccionada != null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_imagenSeleccionada!, height: 60, fit: BoxFit.cover),
                              )
                            : const Text('Sin foto (Se usará por defecto)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sección GPS Estilizada
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _obtenerGPS, 
                        icon: const Icon(Icons.location_on), 
                        label: const Text('Capturar GPS'), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669).withOpacity(0.2), 
                          foregroundColor: const Color(0xFF34D399),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Lat: ${_latitud!.toStringAsFixed(4)}\nLng: ${_longitud!.toStringAsFixed(4)}', 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                if (_isSaving)
                  const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                else
                  ElevatedButton(
                    onPressed: _guardarEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, 
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      shadowColor: Colors.purple.withOpacity(0.4),
                    ),
                    child: const Text('Publicar Fiesta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}