import 'package:supabase_flutter/supabase_flutter.dart';

// Script para asignar manualmente un abogado a un caso de prueba
void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://zohufwabzguzmqxkptqx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvaHVmd2Fiemd1em1xeGtwdHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYzMjYwMjgsImV4cCI6MjA0MTkwMjAyOH0.8kGx7fB0mJLuFQVFXXsQxGT8Jk7i5yZ3c-I1qGVz3zI',
  );

  final supabase = Supabase.instance.client;

  print('🔍 Buscando abogados disponibles...\n');

  try {
    // Buscar abogados (usuarios con tipo 'lawyer')
    final abogadosResponse = await supabase
        .from('user_profiles')
        .select('id, full_name, email, location, phone')
        .eq('user_type', 'lawyer')
        .limit(10);

    if (abogadosResponse.isEmpty) {
      print('❌ No se encontraron abogados en la base de datos');
      print('💡 Necesitas crear al menos un usuario con tipo "lawyer"');
      return;
    }

    print('📋 Abogados disponibles:\n');
    for (var i = 0; i < abogadosResponse.length; i++) {
      final abogado = abogadosResponse[i];
      print('${i + 1}. ${abogado['full_name']} (${abogado['email']})');
      print('   ID: ${abogado['id']}');
      print('   Ubicación: ${abogado['location'] ?? 'No especificada'}');
      print('');
    }

    // Usar el primer abogado para el ejemplo
    final primerAbogado = abogadosResponse[0];
    final lawyerId = primerAbogado['id'];
    final lawyerName = primerAbogado['full_name'];

    print('✅ Vamos a usar: $lawyerName\n');

    // Casos del usuario actual
    final caseId = '2e801c3b-9cb3-4a93-82c0-af12aa60a0ca'; // ID del caso "monica"
    
    print('🔄 Asignando abogado al caso...\n');

    // Actualizar el caso con el abogado asignado
    await supabase
        .from('marketplace_cases')
        .update({
          'assigned_lawyer_id': lawyerId,
          'status': 'assigned',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', caseId);

    print('✅ ¡Abogado asignado exitosamente!\n');
    print('📝 Detalles de la asignación:');
    print('   Caso ID: $caseId');
    print('   Abogado: $lawyerName');
    print('   Abogado ID: $lawyerId');
    print('\n🎉 Ahora puedes abrir el chat del caso "monica" y verás la información del abogado!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
