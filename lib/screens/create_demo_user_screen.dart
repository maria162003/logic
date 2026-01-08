import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Widget temporal para crear usuario demo desde la app
/// Agregar temporalmente en main.dart como ruta /create-demo
class CreateDemoUserScreen extends StatefulWidget {
  const CreateDemoUserScreen({super.key});

  @override
  State<CreateDemoUserScreen> createState() => _CreateDemoUserScreenState();
}

class _CreateDemoUserScreenState extends State<CreateDemoUserScreen> {
  bool _isCreating = false;
  String _message = '';
  bool _success = false;

  Future<void> _createDemoUser() async {
    setState(() {
      _isCreating = true;
      _message = 'Creando usuario demo...';
    });

    try {
      final client = SupabaseConfig.client;
      
      // Credenciales del usuario demo
      const email = 'demo.cliente@logicapp.co';
      const password = 'LogicDemo!234';
      const fullName = 'Demo Cliente';
      const documentType = 'CC';
      const documentNumber = '1012345678';

      // 1. Crear usuario en Auth
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': 'client',
        },
      );

      if (authResponse.user == null) {
        setState(() {
          _message = 'Error: No se pudo crear el usuario en Auth';
          _isCreating = false;
          _success = false;
        });
        return;
      }

      final userId = authResponse.user!.id;

      // 2. Crear perfil en user_profiles
      await client.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'user_type': 'client',
        'document_type': documentType,
        'document_number': documentNumber,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Cerrar sesión
      await client.auth.signOut();

      setState(() {
        _message = '¡Usuario demo creado exitosamente!\n\n'
            'Email: $email\n'
            'Contraseña: $password\n'
            'Nombre: $fullName\n'
            'Tipo: Cliente\n\n'
            'Ya puedes iniciar sesión con estas credenciales.';
        _isCreating = false;
        _success = true;
      });

    } catch (e) {
      setState(() {
        if (e.toString().contains('duplicate') || e.toString().contains('already')) {
          _message = 'El usuario ya existe.\n\n'
              'Email: demo.cliente@logicapp.co\n'
              'Contraseña: LogicDemo!234\n\n'
              'Puedes iniciar sesión directamente.';
          _success = true;
        } else {
          _message = 'Error al crear usuario:\n${e.toString()}';
          _success = false;
        }
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_message.isEmpty) ...[
                const Text(
                  'Crear usuario demo de cliente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email: demo.cliente@logicapp.co\nContraseña: LogicDemo!234',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
              ],
              
              if (_message.isNotEmpty) ...[
                Icon(
                  _success ? Icons.check_circle : Icons.error,
                  color: _success ? Colors.green : Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
              ],
              
              if (_isCreating)
                const CircularProgressIndicator()
              else if (!_success || _message.isEmpty)
                ElevatedButton(
                  onPressed: _createDemoUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Crear Usuario Demo',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Ir a Iniciar Sesión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
