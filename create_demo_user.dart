import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para crear usuario demo cliente en Supabase
/// Ejecutar con: dart run create_demo_user.dart

void main() async {
  print('🚀 Iniciando creación de usuario demo...\n');
  
  // Configuración de Supabase
  const supabaseUrl = 'https://zohufwabzguzmqxkptqx.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvaHVmd2Fiemd1em1xeGtwdHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2NTk5MDEsImV4cCI6MjA3NDIzNTkwMX0.Xro2gFDe0GXDM1iYdpbyDH6F9XHHSR-PD8w6o-L32cs';
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  
  final client = Supabase.instance.client;
  
  // Credenciales del usuario demo
  const email = 'demo.cliente@logicapp.co';
  const password = 'LogicDemo!234';
  const fullName = 'Demo Cliente';
  const documentType = 'CC';
  const documentNumber = '1012345678';
  
  try {
    print('📝 Registrando usuario en Auth...');
    
    // 1. Crear usuario en Auth
    final authResponse = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'user_type': 'client',
      },
      emailRedirectTo: null,
    );
    
    if (authResponse.user == null) {
      print('❌ Error: No se pudo crear el usuario en Auth');
      return;
    }
    
    final userId = authResponse.user!.id;
    print('✅ Usuario creado en Auth con ID: $userId');
    
    // 2. Crear perfil en user_profiles
    print('📝 Creando perfil de usuario...');
    
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
    
    print('✅ Perfil de usuario creado exitosamente');
    
    // Cerrar sesión del usuario demo para que puedas iniciar sesión manualmente
    await client.auth.signOut();
    
    print('\n🎉 ¡Usuario demo creado exitosamente!\n');
    print('═══════════════════════════════════════');
    print('📧 Email: $email');
    print('🔑 Contraseña: $password');
    print('👤 Nombre: $fullName');
    print('📋 Tipo: Cliente');
    print('🆔 Documento: $documentType - $documentNumber');
    print('═══════════════════════════════════════');
    print('\n✨ Ya puedes iniciar sesión en la app con estas credenciales\n');
    
  } catch (e) {
    print('\n❌ Error al crear usuario demo:');
    print(e.toString());
    
    if (e.toString().contains('duplicate') || e.toString().contains('already')) {
      print('\n💡 El usuario ya existe. Puedes iniciar sesión directamente con:');
      print('   Email: $email');
      print('   Contraseña: $password');
    }
  }
}
