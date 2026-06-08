import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; // Agregado para jalar el correo automáticamente
import '../config/constants.dart';
import 'crear_evento_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _eventos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse("${Constants.baseUrl}/events"));
      if (response.statusCode == 200) {
        setState(() {
          _eventos = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error cargando eventos: $e");
    }
  }

  // Función para enviar comentarios directo a tu Laravel
 Future<void> _enviarComentario(int eventId, String contenido) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // BLINDAJE: Si user.email por alguna razón viene null o vacío, 
  // buscamos en los proveedores o usamos el nombre/uid para que NUNCA sea anónimo o falle
  String correoUsuario = user.email ?? "";

  // Si el correo sigue vacío (raro en registros directos, pero pasa), 
  // intentamos sacarlo de los datos del proveedor de Firebase
  if (correoUsuario.isEmpty && user.providerData.isNotEmpty) {
    correoUsuario = user.providerData.first.email ?? "";
  }

  // Si de plano no tiene correo (ej. inicio con teléfono o algo raro), usamos su ID único o un texto identificador
  if (correoUsuario.isEmpty) {
    correoUsuario = user.displayName ?? "Usuario_${user.uid.substring(0, 5)}";
  }

  final response = await http.post(
    Uri.parse("${Constants.baseUrl}/events/$eventId/comments"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      'email': correoUsuario, // Enviamos el correo ya verificado y blindado
      'contenido': contenido,
    }),
  );

  if (response.statusCode == 201) {
    _cargarEventos(); // Recarga para pintar el comentario nuevo
  }
}
  // Lanzador optimizado para saltar directo a WhatsApp en tu Xiaomi
  Future<void> _abrirWhatsApp(String telefono) async {
    if (telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El organizador no dejó número 📱'), backgroundColor: Colors.orange),
      );
      return;
    }

    final numeroLimpio = telefono.replaceAll(RegExp(r'[^\d]'), '');
    final url = "https://wa.me/$numeroLimpio?text=Hola!%20🔥%20Estoy%20interesado%20en%20el%20evento%20de%20Gooooo!%20🎉";
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp 💬'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _abrirGoogleMaps(String latitud, String longitud) async {
    if (latitud.isEmpty || longitud.isEmpty) return;
    
    final url = "geo:$latitud,$longitud?q=$latitud,$longitud(Ubicación de la Fiesta)";
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        final webUrl = "https://www.google.com/maps/search/?api=1&query=$latitud,$longitud";
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Error en mapas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C1B), 
              Color(0xFF150A21), 
              Color(0xFF0A0712), 
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: const Text(
                    'Gooooo !!!! 🕺🎉', 
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8, fontSize: 24)
                  ),
                  backgroundColor: const Color(0xFF0F0C1B).withOpacity(0.8),
                  floating: true,
                  snap: true,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.purpleAccent, size: 26), 
                      onPressed: _cargarEventos
                    )
                  ],
                )
              ];
            },
            body: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                : _eventos.isEmpty
                    ? const Center(
                        child: Text('No hay eventos aún. ¡Sé el primero! 🔥', style: TextStyle(color: Colors.white60)),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _eventos.length,
                        itemBuilder: (context, index) {
                          final ev = _eventos[index];
                          return Card(
                            color: const Color(0xFF1B142C).withOpacity(0.7),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (ev['imagen'] != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                    child: Image.network(
                                      ev['imagen'], 
                                      height: 190, 
                                      width: double.infinity, 
                                      fit: BoxFit.cover, 
                                      errorBuilder: (c, e, s) => Container(
                                        height: 130, color: Colors.purple.withOpacity(0.05),
                                        child: const Center(child: Icon(Icons.broken_image, color: Colors.purpleAccent)),
                                      )
                                    ),
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                    child: Container(
                                      height: 140, color: Colors.purple.withOpacity(0.08), 
                                      child: const Center(child: Icon(Icons.festival_rounded, size: 54, color: Colors.purpleAccent))
                                    ),
                                  ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ev['titulo'] ?? '', 
                                        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white)
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ev['descripcion'] ?? '', 
                                        style: const TextStyle(color: Colors.white60, fontSize: 14)
                                      ),
                                      const Divider(height: 28, color: Colors.white12), 
                                      
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.purpleAccent),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Fecha: ${ev['fecha'] ?? 'Por confirmar'}", 
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12), 
                                      
                                      Row(
                                        children: [
                                          const Icon(Icons.school_rounded, size: 18, color: Colors.white38),
                                          const SizedBox(width: 8),
                                          Text(
                                            ev['nivel_educativo'] ?? 'Primaria', 
                                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)
                                          ),
                                          
                                          const Spacer(),
                                          const Icon(Icons.confirmation_number_rounded, size: 18, color: Color(0xFF34D399)),
                                          const SizedBox(width: 6),
                                          
                                          Text(
                                            "S/. ${ev['precio'] ?? '0.00'}", 
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34D399), fontSize: 16)
                                          ),
                                        ],
                                      ),

                                      // SECCIÓN DE COMENTARIOS AHORA CON MENÚ DESGLOSABLE (ExpansionTile)
                                      const Divider(height: 28, color: Colors.white12),
                                      Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          tilePadding: EdgeInsets.zero,
                                          title: Text(
                                            "Comentarios (${(ev['comments'] as List? ?? []).length})", 
                                            style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)
                                          ),
                                          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.cyanAccent, size: 20),
                                          children: [
                                            const SizedBox(height: 6),
                                            ...List.generate((ev['comments'] as List? ?? []).length, (i) {
                                              final comment = ev['comments'][i];
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.all(10),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0D0D1F),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(comment['usuario'] ?? 'Anónimo', style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 2),
                                                    Text(comment['contenido'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),

                                      // BOTÓN PARA COMENTAR ORIGINAL (Mantiene tu showDialog intacto)
                                      TextButton.icon(
                                        onPressed: () {
                                          final controller = TextEditingController();
                                          showDialog(context: context, builder: (c) => AlertDialog(
                                            backgroundColor: const Color(0xFF1B142C),
                                            title: const Text("Escribe un comentario", style: TextStyle(color: Colors.white, fontSize: 16)),
                                            content: TextField(
                                              controller: controller, 
                                              style: const TextStyle(color: Colors.white), 
                                              decoration: const InputDecoration(hintText: "Escribe algo...", hintStyle: TextStyle(color: Colors.white38))
                                            ),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: Colors.white54))),
                                              TextButton(
                                                onPressed: () { 
                                                  _enviarComentario(ev['id'], controller.text); 
                                                  Navigator.pop(c); 
                                                }, 
                                                child: const Text("Enviar", style: TextStyle(color: Colors.purpleAccent))
                                              )
                                            ],
                                          ));
                                        },
                                        icon: const Icon(Icons.comment_rounded, color: Colors.purpleAccent, size: 18),
                                        label: const Text("Comentar", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                                      ),

                                      const Divider(height: 28, color: Colors.white12),
                                      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => _abrirWhatsApp(ev['telefono']?.toString() ?? ''),
                                            icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF34D399), size: 18),
                                            label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                                            style: TextButton.styleFrom(
                                              backgroundColor: const Color(0xFF059669).withOpacity(0.15),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              _abrirGoogleMaps(
                                                ev['latitud']?.toString() ?? '', 
                                                ev['longitud']?.toString() ?? ''
                                              );
                                            },
                                            icon: const Icon(Icons.map_rounded, color: Colors.blueAccent, size: 18),
                                            label: const Text('Ver Mapa', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.blueAccent.withOpacity(0.15),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, size: 30),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearEventoScreen()),
          );
          if (result == true) {
            _cargarEventos(); 
          }
        },
      ),
    );
  }
}