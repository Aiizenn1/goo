import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generado automáticamente por FlutterFire CLI
import 'services/auth_service.dart';
import 'screens/auth_screen.dart'; // Pantalla que alterna Login y Registro de Laravel
import 'screens/home_screen.dart'; // Pantalla principal del CRUD de Fiestas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Nota: Firebase no se pudo inicializar o ya estaba listo: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gooooo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark, // Cambiado a oscuro global para la app
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Sincronizado con el fondo Cyber Midnight Premium de todo el ecosistema
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C1B), // Azul noche profundo espacial
              Color(0xFF150A21), // Violeta místico oscuro
              Color(0xFF0A0712), // Negro neón suave
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono con aura neón fiestera
  Container(
  width: 130,
  height: 130,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.purple.withOpacity(0.15),
    border: Border.all(
      color: Colors.purpleAccent.withOpacity(0.4),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.purpleAccent.withOpacity(0.25),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(8),
    child: ClipOval(
      child: Image.asset(
        'images/goo.png',
        fit: BoxFit.cover,
      ),
    ),
  ),
),

                    const SizedBox(height: 24),
                    
                    const Text(
                      'Gooooo Party !!! 🔥',
                      style: TextStyle(
                        fontSize: 34, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white,
                        letterSpacing: 0.8
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '¡Bienvenidos al goooooooo!!! 🥳\nEncuentra tus fiestas y eventos favoritos',
                      style: TextStyle(
                        fontSize: 15, 
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        height: 1.4
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 54),

                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.purpleAccent)
                    else ...[
                      // Botón de Correo: Llama a la pantalla AuthScreen de Laravel
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthScreen()),
                          );
                        },
                        icon: const Icon(Icons.email_rounded, color: Colors.white),
                        label: const Text(
                          'Iniciar con Correo', 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          minimumSize: const Size(double.infinity, 54),
                          elevation: 4,
                          shadowColor: Colors.purple.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Botón de Google (Firebase)
                      OutlinedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            final authService = AuthService();
                            final userCredential = await authService.signInWithGoogle();
                            setState(() => _isLoading = false);

                            if (userCredential != null) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('¡Bienvenido, ${userCredential.user?.displayName}! 🎉🕺'),
                                  backgroundColor: const Color(0xFF059669), // Esmeralda Premium
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Inicio de sesión cancelado.'), 
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => _isLoading = false);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error de autenticación: $e'), 
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 36, color: Colors.purpleAccent),
                        label: const Text(
                          'Iniciar con Google', 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B142C).withOpacity(0.6),
                          minimumSize: const Size(double.infinity, 54),
                          side: BorderSide(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}