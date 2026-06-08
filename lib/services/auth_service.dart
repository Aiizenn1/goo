import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 1. Instanciación limpia y actualizada para google_sign_in: ^7.2.0
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Función principal solicitada en el Punto 1 del PDF [cite: 149]
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 2. Ejecutar el inicio de sesión nativo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("El usuario canceló el inicio de sesión.");
        return null; 
      }

      // 3. Obtener los detalles de autenticación con la firma de la versión 7.x
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Crear la credencial mapeando de forma segura para Firebase Auth 6.x
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Iniciar sesión en Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 6. Sincronización con tu API Laravel en DigitalOcean [cite: 156, 225]
      if (userCredential.user != null) {
        await syncWithLaravelServer(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print("Error detectado en Google Sign In: $e");
      return null;
    }
  }

  // Método de sincronización con la IP de tu Droplet
  Future<void> syncWithLaravelServer(User user) async {
    final url = Uri.parse("${Constants.baseUrl}/auth/google-sync");
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": user.displayName,
          "email": user.email,
          "google_id": user.uid,
          "avatar": user.photoURL,
        }),
      );

      if (response.statusCode == 200) {
        print("Sincronizado con Laravel en 143.198.124.161 correctamente.");
      } else {
        print("La API respondió con error: ${response.body}");
      }
    } catch (e) {
      print("Error de conexión de red con DigitalOcean: $e");
    }
  }
}