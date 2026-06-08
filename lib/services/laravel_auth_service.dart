import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class LaravelAuthService {
  /// Registra un nuevo usuario en el backend de Laravel
  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse("${Constants.baseUrl}/register");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, 
        }),
      );

      print("--- RESPUESTA REGISTRO LARAVEL ---");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("----------------------------------");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error crítico en el servicio de registro: $e");
      return false;
    }
  }

  /// Inicia sesión de un usuario existente y devuelve los datos si es exitoso
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse("${Constants.baseUrl}/login");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("--- RESPUESTA LOGIN LARAVEL ---");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("-------------------------------");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error crítico en el servicio de login: $e");
      return null;
    }
  }
}