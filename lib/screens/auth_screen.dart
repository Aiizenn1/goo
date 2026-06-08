import 'package:flutter/material.dart';
import '../services/laravel_auth_service.dart';
import 'home_screen.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true; 
  bool _isLoading = false;
  bool _obscurePassword = true; 
  final _authService = LaravelAuthService();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    if (_isLogin) {
      // ==================== INICIO DE SESIÓN ====================
      final result = await _authService.login(
        _emailController.text.trim(), 
        _passwordController.text.trim()
      );
      
      setState(() => _isLoading = false);

      if (result != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido de vuelta! 🎉'), 
            backgroundColor: Color(0xFF059669), // Color Esmeralda Premium corregido
            behavior: SnackBarBehavior.floating,
          ),
        );

        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas o error en el servidor. ❌'), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // ==================== REGISTRO DE USUARIO ====================
      final success = await _authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim()
      );

      setState(() => _isLoading = false);

      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada con éxito! Por favor inicia sesión. 🔑'), 
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _passwordController.clear(); 
        
        setState(() {
          _isLogin = true; 
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar. El correo podría estar en uso.'), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              Color(0xFF311B92), 
              Color(0xFF6A1B9A), 
              Color(0xFF8E24AA), 
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.festival_rounded, 
                      size: 64, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    _isLogin ? '¡Bienvenido!' : 'Únete a la Fiesta',
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w800, 
                      color: Colors.white,
                      letterSpacing: 0.5
                    ),
                  ),
                  Text(
                    _isLogin ? 'Inicia sesión para continuar' : 'Crea tu cuenta en pocos pasos',
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.white.withOpacity(0.7)
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Nombre Completo',
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.purple),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.purple, width: 2),
                                ),
                              ),
                              validator: (val) => val!.isEmpty ? 'Ingresa tu nombre' : null,
                            ),
                            const SizedBox(height: 18),
                          ],
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.black87),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: const Icon(Icons.mail_outline, color: Colors.purple),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.purple, width: 2),
                              ),
                            ),
                            validator: (val) => !val!.contains('@') ? 'Ingresa un correo válido' : null,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.black87),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.purple),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.purple, width: 2),
                              ),
                            ),
                            validator: (val) => val!.length < 6 ? 'Mínimo 6 caracteres' : null,
                          ),
                          const SizedBox(height: 28),
                          
                          if (_isLoading)
                            const CircularProgressIndicator(color: Colors.purple)
                          else ...[
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 54),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _isLogin ? 'INGRESAR' : 'REGISTRARME', 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formKey.currentState?.reset(); 
                                });
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.purple),
                              child: Text(
                                _isLogin ? '¿No tienes cuenta? Regístrate aquí' : '¿Ya tienes cuenta? Inicia sesión',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                    label: const Text('Volver al inicio', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}