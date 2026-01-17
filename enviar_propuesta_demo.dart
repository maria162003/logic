import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para ver casos abiertos y enviar una propuesta demo
void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://zohufwabzguzmqxkptqx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvaHVmd2Fiemd1em1xeGtwdHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2NjkwMTEsImV4cCI6MjA3NDI0NTAxMX0.Xro2gFDe0GXDM1iYdpbyDH6F9XHHSR-PD8w6o-L32cs',
  );

  final supabase = Supabase.instance.client;

  print('=' * 60);
  print('🔍 CASOS ABIERTOS EN EL MARKETPLACE');
  print('=' * 60);

  try {
    // 1. Ver casos abiertos
    final casosAbiertos = await supabase
        .from('marketplace_cases')
        .select('id, title, description, legal_area, budget, client_id, created_at')
        .eq('status', 'open')
        .order('created_at', ascending: false);

    if (casosAbiertos.isEmpty) {
      print('❌ No hay casos abiertos actualmente');
      return;
    }

    print('\n📋 Casos abiertos encontrados: ${casosAbiertos.length}\n');
    
    for (var i = 0; i < casosAbiertos.length; i++) {
      final caso = casosAbiertos[i];
      print('${i + 1}. ${caso['title']}');
      print('   ID: ${caso['id']}');
      print('   Área legal: ${caso['legal_area']}');
      print('   Presupuesto: \$${caso['budget']} COP');
      print('   Descripción: ${(caso['description'] ?? '').toString().substring(0, (caso['description']?.toString().length ?? 0) > 80 ? 80 : (caso['description']?.toString().length ?? 0))}...');
      print('');
    }

    // 2. Ver abogados disponibles
    print('=' * 60);
    print('👨‍⚖️ ABOGADOS DISPONIBLES');
    print('=' * 60);

    final abogados = await supabase
        .from('user_profiles')
        .select('id, full_name, email, location, is_student, specializations')
        .eq('user_type', 'lawyer')
        .limit(10);

    if (abogados.isEmpty) {
      print('❌ No hay abogados registrados');
      return;
    }

    print('\n📋 Abogados encontrados: ${abogados.length}\n');
    
    for (var i = 0; i < abogados.length; i++) {
      final abogado = abogados[i];
      final tipo = abogado['is_student'] == true ? 'Estudiante' : 'Profesional';
      print('${i + 1}. ${abogado['full_name']} ($tipo)');
      print('   ID: ${abogado['id']}');
      print('   Email: ${abogado['email']}');
      print('   Ubicación: ${abogado['location'] ?? 'No especificada'}');
      print('');
    }

    // 3. Enviar propuesta del primer abogado al primer caso
    print('=' * 60);
    print('📝 ENVIANDO PROPUESTA DE PRUEBA');
    print('=' * 60);

    final primerCaso = casosAbiertos[0];
    final primerAbogado = abogados[0];
    
    final caseId = primerCaso['id'];
    final clientId = primerCaso['client_id'];
    final lawyerId = primerAbogado['id'];
    final lawyerName = primerAbogado['full_name'];
    final caseTitle = primerCaso['title'];

    print('\n🔄 Enviando propuesta...');
    print('   Caso: $caseTitle');
    print('   Abogado: $lawyerName');

    // Verificar si ya existe una propuesta de este abogado para este caso
    final existente = await supabase
        .from('proposals')
        .select('id')
        .eq('case_id', caseId)
        .eq('lawyer_id', lawyerId)
        .maybeSingle();

    if (existente != null) {
      print('\n⚠️ Ya existe una propuesta de este abogado para este caso');
      print('   Propuesta ID: ${existente['id']}');
      return;
    }

    // Insertar propuesta
    await supabase.from('proposals').insert({
      'case_id': caseId,
      'client_id': clientId,
      'lawyer_id': lawyerId,
      'message': '''Estimado cliente,

Me interesa mucho su caso. Tengo amplia experiencia en ${primerCaso['legal_area']} y puedo ayudarle a resolver su situación de manera efectiva.

Mi enfoque es personalizado y me aseguro de mantener una comunicación constante con mis clientes para que estén informados de cada paso del proceso.

Lorem Ipsum es simplemente el texto de relleno de las imprentas y archivos de texto. Lorem Ipsum ha sido el texto de relleno estándar de las industrias desde el año 1500, cuando un impresor desconocido usó una galería de textos y los mezcló de tal manera que logró hacer un libro de textos especimen.

Quedo atento a sus comentarios.

Saludos cordiales,
$lawyerName''',
      'proposed_fee': 870000,
      'estimated_days': 30,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    print('\n✅ ¡Propuesta enviada exitosamente!');
    print('\n📌 Ahora puedes ver la propuesta en el Panel del Cliente');
    print('   en la sección "Mis Casos" → caso "$caseTitle" → Ver ofertas');

  } catch (e, stack) {
    print('❌ Error: $e');
    print('Stack: $stack');
  }
}
