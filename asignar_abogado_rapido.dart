import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔄 Conectando a Supabase...');
  
  await Supabase.initialize(
    url: 'https://zohufwabzguzmqxkptqx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvaHVmd2Fiemd1em1xeGtwdHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYzMjYwMjgsImV4cCI6MjA0MTkwMjAyOH0.8kGx7fB0mJLuFQVFXXsQxGT8Jk7i5yZ3c-I1qGVz3zI',
  );

  final supabase = Supabase.instance.client;

  try {
    // 1. Ver abogados disponibles
    print('\n📋 Buscando abogados...');
    final abogados = await supabase
        .from('user_profiles')
        .select('id, full_name, email, location')
        .eq('user_type', 'lawyer')
        .limit(5);

    if (abogados.isEmpty) {
      print('❌ No hay abogados registrados');
      return;
    }

    print('\n✅ Abogados disponibles:');
    for (var i = 0; i < abogados.length; i++) {
      print('${i + 1}. ${abogados[i]['full_name']} - ${abogados[i]['location'] ?? 'Sin ubicación'}');
      print('   ID: ${abogados[i]['id']}');
    }

    // 2. Ver casos del cliente actual
    print('\n📂 Casos sin abogado asignado:');
    final casos = await supabase
        .from('marketplace_cases')
        .select('id, title, status, assigned_lawyer_id')
        .eq('client_id', '37f86726-e6c2-4c31-a1ac-7380fdc490c5')
        .is_('assigned_lawyer_id', null);

    if (casos.isEmpty) {
      print('ℹ️  Todos los casos ya tienen abogado asignado');
      return;
    }

    for (var i = 0; i < casos.length; i++) {
      print('${i + 1}. ${casos[i]['title']} (ID: ${casos[i]['id']})');
    }

    // 3. Asignar primer abogado al primer caso
    final abogadoId = abogados[0]['id'];
    final casoId = casos[0]['id'];
    
    print('\n🔄 Asignando ${abogados[0]['full_name']} al caso "${casos[0]['title']}"...');
    
    await supabase
        .from('marketplace_cases')
        .update({
          'assigned_lawyer_id': abogadoId,
          'status': 'assigned',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', casoId);

    print('✅ ¡Abogado asignado exitosamente!');
    print('');
    print('📱 Ahora puedes:');
    print('   1. Presiona "r" en la terminal de Flutter para hot reload');
    print('   2. Abre el chat del caso "${casos[0]['title']}"');
    print('   3. Verás el nombre y foto del abogado: ${abogados[0]['full_name']}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
