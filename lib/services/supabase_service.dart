import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => SupabaseConfig.client;

  // ========================================
  // AUTENTICACIÓN
  // ========================================

  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Registro de usuario
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType, // 'client' o 'lawyer'
    String? phone,
    String? location,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'user_type': userType,
        'phone': phone,
        'location': location,
      },
    );

    // Crear perfil después del registro exitoso
    if (response.user != null) {
      // Esperar un poco para que el usuario se confirme en el sistema
      await Future.delayed(const Duration(milliseconds: 500));
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
        userType: userType,
        phone: phone,
        location: location,
      );
    }

    return response;
  }

  // Iniciar sesión
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión completamente
  static Future<void> signOut() async {
    try {
      print('🔄 Cerrando sesión...');
      await client.auth.signOut(scope: SignOutScope.global);
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('⚠️ Error al cerrar sesión: $e');
      // Forzar limpieza local incluso si hay error
      await client.auth.signOut(scope: SignOutScope.local);
    }
  }

  // Reenviar email de verificación
  static Future<void> resendVerificationEmail({
    required String email,
  }) async {
    await client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // Crear perfil de usuario
  static Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String userType,
    String? phone,
    String? location,
  }) async {
    try {
      // Usar upsert en lugar de insert para evitar conflictos
      await client.from('user_profiles').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'user_type': userType,
        'phone': phone,
        'location': location,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      // Si es abogado, crear registro en tabla lawyer_profiles
      if (userType == 'lawyer') {
        await client.from('lawyer_profiles').upsert({
          'id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
      }
    } catch (e) {
      print('Error creating user profile: $e');
      // No lanzar error para no interrumpir el flujo de registro
      // El perfil se puede crear más tarde
    }
  }

  // Obtener perfil de usuario
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('🔍 SUPABASE: Consultando perfil para usuario $userId');

      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        print('📋 SUPABASE: Perfil encontrado: $response');
        return response;
      }

      print('⚠️ SUPABASE: No se encontró perfil para usuario $userId');
      return null;
    } catch (e) {
      print('❌ SUPABASE: Error consultando perfil: $e');
      return null;
    }
  }

  // Actualizar perfil de usuario
  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['updated_at'] = DateTime.now().toIso8601String();

      print('🔄 SUPABASE: Actualizando perfil para usuario $userId');
      print('📝 SUPABASE: Datos a actualizar: $updateData');

      await client.from('user_profiles').update(updateData).eq('id', userId);
      print('✅ SUPABASE: Perfil actualizado correctamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en updateUserProfile: $e');
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Crear perfil manualmente (método público para casos donde falle la creación inicial)
  static Future<bool> createUserProfileManually({
    required String fullName,
    required String userType,
    String? phone,
    String? location,
  }) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      await _createUserProfile(
        userId: user.id,
        email: user.email ?? '',
        fullName: fullName,
        userType: userType,
        phone: phone,
        location: location,
      );
      return true;
    } catch (e) {
      print('Error creating profile manually: $e');
      return false;
    }
  }

  // ========================================
  // MARKETPLACE DE CASOS
  // ========================================

  // Obtener casos disponibles en el marketplace
  static Future<List<Map<String, dynamic>>> getMarketplaceCases({
    String? category,
    String? location,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = client.from('marketplace_cases').select('*');

      // CORREGIDO: Solo mostrar casos abiertos en el marketplace público
      // Los casos 'assigned' ya no están disponibles para nuevas propuestas
      query = query.eq('status', 'open');

      if (category != null && category != 'Todas') {
        query = query.eq('category', category);
      }

      if (location != null && location != 'Nacional') {
        query = query.eq('location', location);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print(
          '✅ SUPABASE: getMarketplaceCases exitoso - ${response.length} casos ABIERTOS encontrados');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE: Error al obtener casos del marketplace: $e');
      return [];
    }
  }

  // Crear nuevo caso en el marketplace
  static Future<String> createMarketplaceCase({
    required String title,
    required String description,
    required String category,
    double? budget,
    String? location,
    String urgency = 'medium',
    DateTime? deadline,
    List<String>? documents,
  }) async {
    print('🔍 SUPABASE SERVICE: Iniciando createMarketplaceCase...');

    final user = currentUser;
    if (user == null) {
      print('❌ SUPABASE SERVICE: Usuario no autenticado');
      throw Exception('Usuario no autenticado');
    }

    print('👤 SUPABASE SERVICE: Usuario ID: ${user.id}');

    final caseData = {
      'client_id': user.id,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'location': location,
      'urgency': urgency,
      'deadline': deadline?.toIso8601String(),
      'documents': documents ?? [],
    };

    print('📝 SUPABASE SERVICE: Datos del caso a insertar: $caseData');

    try {
      final response = await client
          .from('marketplace_cases')
          .insert(caseData)
          .select()
          .single();
      print(
          '✅ SUPABASE SERVICE: Caso insertado exitosamente: ${response['id']}');
      return response['id'];
    } catch (e) {
      print('❌ SUPABASE SERVICE: Error al insertar caso: $e');
      rethrow;
    }
  }

  // Eliminar caso de marketplace (solo si no está asignado)
  static Future<void> deleteMarketplaceCaseIfNotAssigned({
    required String caseId,
    required String clientId,
  }) async {
    try {
      print('🔍 SUPABASE: Verificando si el caso puede ser eliminado...');

      // Verificar que el caso pertenece al cliente y no está asignado
      final caseData = await client
          .from('marketplace_cases')
          .select('id, title, status, client_id')
          .eq('id', caseId)
          .eq('client_id', clientId)
          .single();

      if (caseData['status'] != 'open') {
        throw Exception(
            'No se puede eliminar un caso que ya ha sido asignado a un abogado');
      }

      print('✅ SUPABASE: Caso verificado, procediendo con eliminación...');

      // Eliminar propuestas relacionadas primero
      await client.from('proposals').delete().eq('case_id', caseId);

      print('✅ SUPABASE: Propuestas relacionadas eliminadas');

      // Eliminar el caso
      await client
          .from('marketplace_cases')
          .delete()
          .eq('id', caseId)
          .eq('client_id', clientId);

      print('✅ SUPABASE: Caso eliminado exitosamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en deleteMarketplaceCaseIfNotAssigned: $e');
      throw Exception('Error al eliminar caso: $e');
    }
  }

  // Obtener casos del cliente
  static Future<List<Map<String, dynamic>>> getClientCases() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // Primero obtener casos del marketplace del cliente
      final marketplaceCases = await client
          .from('marketplace_cases')
          .select('*')
          .eq('client_id', user.id)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> cases =
          List<Map<String, dynamic>>.from(marketplaceCases);

      // Para cada caso, verificar si tiene un caso activo asociado
      for (var case_ in cases) {
        String caseId = case_['id'];

        try {
          // Buscar caso activo relacionado usando case_id
          var activeCases = await client
              .from('active_cases')
              .select('id, agreed_fee, lawyer_id, status')
              .eq('case_id', caseId)
              .limit(1);

          if (activeCases.isNotEmpty) {
            var activeCase = activeCases.first;

            // Obtener información del abogado
            var lawyerProfile = await client
                .from('user_profiles')
                .select('full_name')
                .eq('id', activeCase['lawyer_id'])
                .single();

            // Crear estructura compatible con el código existente
            case_['accepted_proposal'] = {
              'proposed_fee': activeCase['agreed_fee'],
              'lawyer_id': activeCase['lawyer_id'],
              'status': 'accepted',
              'lawyer_profile': lawyerProfile,
            };
          } else if (case_['status'] == 'open') {
            // Para casos abiertos, cargar las propuestas pendientes
            case_['accepted_proposal'] = null;

            // Obtener propuestas pendientes para este caso
            try {
              final proposals = await client
                  .from('proposals')
                  .select('''
                    *,
                    lawyer_profile:lawyer_id(
                      id,
                      full_name,
                      profile_image_url,
                      location,
                      user_type
                    )
                  ''')
                  .eq('case_id', caseId)
                  .eq('status', 'pending')
                  .order('created_at', ascending: false);

              case_['proposals'] = List<Map<String, dynamic>>.from(proposals);
              print(
                  '📋 Caso $caseId: ${proposals.length} propuestas pendientes');
            } catch (e) {
              print('⚠️ Error al cargar propuestas para caso $caseId: $e');
              case_['proposals'] = [];
            }
          }
        } catch (e) {
          print('⚠️ Error al buscar caso activo para ${caseId}: $e');
          // Si hay error, dejar el caso sin propuesta aceptada
          case_['accepted_proposal'] = null;
        }
      }

      print(
          '✅ SUPABASE: getClientCases exitoso - ${cases.length} casos encontrados');
      return cases;
    } catch (e) {
      print('❌ SUPABASE ERROR en getClientCases: $e');
      return [];
    }
  }

  // ========================================
  // SISTEMA DE PROPUESTAS
  // ========================================

  // Enviar propuesta a un caso
  static Future<void> sendProposal({
    required String caseId,
    required String message,
    required double proposedFee,
    required int estimatedDays,
    Map<String, dynamic>? proposalDetails,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    print('🔍 Usuario autenticado: ${user.id}');
    print('📄 Caso ID: $caseId');

    // Verificar si el usuario existe en la tabla lawyers, si no, crearlo
    print('🔧 Verificando si usuario existe como abogado...');
    await _ensureLawyerExists(user.id);
    print('🔧 Verificación de abogado completada');

    // Obtener información del caso
    final caseData = await client
        .from('marketplace_cases')
        .select('client_id, title')
        .eq('id', caseId)
        .single();

    print('📋 Datos del caso: $caseData');

    // Verificar que el usuario no sea el cliente del caso
    if (user.id == caseData['client_id']) {
      throw Exception('No puedes enviar propuesta a tu propio caso');
    }

    // Insertar propuesta
    final proposalData = {
      'case_id': caseId,
      'lawyer_id': user.id,
      'client_id': caseData['client_id'],
      'message': message,
      'proposed_fee': proposedFee,
      'estimated_days': estimatedDays,
      'proposal_details': proposalDetails,
    };

    print('📝 Datos de la propuesta a insertar: $proposalData');

    final result = await client.from('proposals').insert(proposalData);

    print('✅ Propuesta insertada: $result');

    // TODO: Crear notificación para el cliente cuando se resuelva el esquema de DB
    // await createNotification(
    //   userId: caseData['client_id'],
    //   type: 'proposal',
    //   title: 'Nueva propuesta recibida',
    //   message: 'Has recibido una propuesta para: ${caseData['title']}',
    //   relatedId: caseId,
    // );

    print('🔔 Notificación saltada temporalmente');
  }

  // Asegurar que el usuario existe en la tabla lawyers
  static Future<void> _ensureLawyerExists(String userId) async {
    print(
        '🔍 _ensureLawyerExists: Iniciando verificación para userId: $userId');
    try {
      // Primero verificar si es estudiante - no necesita lawyer_profile
      final userProfile = await client
          .from('user_profiles')
          .select('user_type')
          .eq('id', userId)
          .maybeSingle();

      if (userProfile != null && userProfile['user_type'] == 'student') {
        print(
            '📚 _ensureLawyerExists: Usuario es estudiante, no necesita lawyer_profile');
        return;
      }

      // Verificar si ya existe como abogado
      print('🔍 _ensureLawyerExists: Consultando tabla lawyer_profiles...');
      final existing = await client
          .from('lawyer_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing != null) {
        print('✅ _ensureLawyerExists: Usuario ya existe como abogado');
        return;
      }

      // Si no existe, crearlo con datos básicos solo si es abogado
      if (userProfile != null && userProfile['user_type'] == 'lawyer') {
        print('🔧 _ensureLawyerExists: Usuario no existe, creando registro...');
        await client.from('lawyer_profiles').insert({
          'id': userId,
          'specializations': ['General'],
          'years_experience': 1,
          'hourly_rate': 50000,
          'is_verified': false,
          'rating': 0.0,
          'total_reviews': 0,
        });

        print(
            '✅ _ensureLawyerExists: Usuario registrado como abogado automáticamente');
      }
    } catch (e) {
      print('⚠️ _ensureLawyerExists: Error verificando/creando abogado: $e');
      // Si falla, intentar de todas formas - puede que ya exista
      rethrow; // Re-lanzar el error para que se pueda manejar arriba
    }
  }

  // Obtener propuestas del abogado con información del caso
  static Future<List<Map<String, dynamic>>> getLawyerProposals() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await client.from('proposals').select('''
            *,
            marketplace_cases!inner(
              id,
              title,
              description,
              category,
              budget,
              location,
              status,
              created_at
            )
          ''').eq('lawyer_id', user.id).order('created_at', ascending: false);

      print(
          '✅ SUPABASE: getLawyerProposals exitoso - ${response.length} propuestas encontradas');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE: Error en getLawyerProposals: $e');
      return [];
    }
  }

  // Obtener casos reales que el abogado aceptó a través de propuestas
  static Future<List<Map<String, dynamic>>> getLawyerAcceptedCases() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('marketplace_cases')
          .select('''
            *,
            proposals!inner(
              id,
              status,
              proposed_fee,
              estimated_days,
              lawyer_id
            )
          ''')
          .eq('proposals.lawyer_id', user.id)
          .eq('proposals.status', 'accepted')
          .order('created_at', ascending: false);

      print(
          '✅ SUPABASE: getLawyerAcceptedCases exitoso - ${response.length} casos encontrados');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE: Error en getLawyerAcceptedCases: $e');
      return [];
    }
  }

  // Obtener casos activos del abogado (tabla interna active_cases)
  static Future<List<Map<String, dynamic>>> getLawyerActiveCases() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('active_cases')
          .select('*')
          .eq('lawyer_id', user.id)
          .order('created_at', ascending: false);

      print(
          '✅ SUPABASE: getLawyerActiveCases exitoso - ${response.length} casos activos encontrados');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE: Error en getLawyerActiveCases: $e');
      return [];
    }
  }

  // Actualizar estado de un caso
  static Future<void> updateCaseStatus(String caseId, String newStatus) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await client.from('marketplace_cases').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', caseId);

      print('✅ SUPABASE: Estado del caso actualizado exitosamente');
    } catch (e) {
      print('❌ SUPABASE: Error al actualizar estado del caso: $e');
      throw e;
    }
  }

  // Obtener casos activos del cliente
  static Future<List<Map<String, dynamic>>> getClientActiveCases() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('active_cases')
          .select('*')
          .eq('client_id', user.id)
          .order('created_at', ascending: false);

      print(
          '✅ SUPABASE: getClientActiveCases exitoso - ${response.length} casos activos encontrados');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE: Error en getClientActiveCases: $e');
      return [];
    }
  }

  // Obtener propuestas recibidas por el cliente (SOLO PENDIENTES)
  static Future<List<Map<String, dynamic>>> getClientProposals() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // Query con JOIN para obtener información del abogado y del caso
      final response = await client
          .from('proposals')
          .select('''
            *,
            lawyer_profile:lawyer_id(id, full_name, profile_image_url, location),
            case_details:case_id(id, title, description, category, budget, status)
          ''')
          .eq('client_id', user.id)
          .eq('status', 'pending') // Solo propuestas pendientes
          .order('created_at', ascending: false);

      print(
          '✅ SUPABASE: getClientProposals exitoso - ${response.length} propuestas PENDIENTES encontradas');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE: Error en getClientProposals: $e');
      return [];
    }
  }

  // Actualizar estado de propuesta
  static Future<void> updateProposalStatus({
    required String proposalId,
    required String status, // 'accepted', 'rejected', 'withdrawn'
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      print('🔄 SUPABASE: Actualizando propuesta $proposalId a estado $status');

      // Obtener datos de la propuesta
      final proposalData = await client
          .from('proposals')
          .select('*')
          .eq('id', proposalId)
          .single();

      print('✅ SUPABASE: Datos de propuesta obtenidos: ${proposalData.keys}');
      print('🔍 PROPUESTA ESPECÍFICA ID: $proposalId');
      print('🔍 LAWYER_ID de esta propuesta: ${proposalData['lawyer_id']}');

      // Actualizar estado
      await client
          .from('proposals')
          .update({'status': status}).eq('id', proposalId);

      print('✅ SUPABASE: Estado de propuesta actualizado exitosamente');

      // Si se acepta la propuesta, crear caso activo y cambiar estado del caso del marketplace
      if (status == 'accepted') {
        await _acceptProposal(proposalData);
        print('✅ SUPABASE: Propuesta aceptada y caso activo creado');
      }
    } catch (e, stackTrace) {
      print('❌ SUPABASE ERROR en updateProposalStatus: $e');
      print('Stack trace: $stackTrace');
      throw Exception('No se pudo actualizar el estado de la propuesta: $e');
    }

    // TODO: Crear notificación cuando se resuelva el esquema de DB
    // final isClient = user.id == proposalData['client_id'];
    // final recipientId = isClient ? proposalData['lawyer_id'] : proposalData['client_id'];
    // await createNotification(
    //   userId: recipientId,
    //   type: 'proposal',
    //   title: 'Propuesta $status',
    //   message: status == 'accepted'
    //       ? 'Tu propuesta para "${proposalData['marketplace_cases']['title']}" ha sido aceptada'
    //       : 'Tu propuesta para "${proposalData['marketplace_cases']['title']}" ha sido ${status == 'rejected' ? 'rechazada' : 'retirada'}',
    //   relatedId: proposalId,
    // );
  }

  // Aceptar propuesta y crear caso activo
  static Future<void> _acceptProposal(Map<String, dynamic> proposalData) async {
    try {
      print('🔄 SUPABASE: Iniciando aceptación de propuesta');
      print('Proposal data keys: ${proposalData.keys}');
      print('🔍 PROPOSAL DATA COMPLETA: $proposalData');
      print('🎯 LAWYER_ID que se va a asignar: ${proposalData['lawyer_id']}');

      // 1. Primero actualizar el estado de la propuesta a 'accepted'
      await client
          .from('proposals')
          .update({'status': 'accepted'}).eq('id', proposalData['id']);

      print('✅ SUPABASE: Propuesta marcada como aceptada');

      // 2. Obtener datos del caso del marketplace
      final caseData = await client
          .from('marketplace_cases')
          .select('*')
          .eq('id', proposalData['case_id'])
          .single();

      print('✅ SUPABASE: Datos del caso obtenidos: ${caseData.keys}');

      // 3. Crear caso activo (usando solo las columnas que existen)
      final activeCaseData = {
        'client_id': proposalData['client_id'],
        'lawyer_id': proposalData['lawyer_id'],
        'case_id': proposalData['case_id'],
        'agreed_fee': proposalData['proposed_fee'],
        'status': 'active',
        // Solo usar columnas que existen en active_cases: id, case_id, lawyer_id, client_id, status, agreed_fee, start_date, end_date, progress, notes, created_at, updated_at
      };

      print('🔍 ACTIVE_CASE_DATA que se va a insertar: $activeCaseData');

      await client.from('active_cases').insert(activeCaseData);

      print('✅ SUPABASE: Caso activo creado');

      // 4. Actualizar estado del caso del marketplace
      await client
          .from('marketplace_cases')
          .update({'status': 'assigned'}).eq('id', proposalData['case_id']);

      print('✅ SUPABASE: Estado del caso del marketplace actualizado');

      // 5. Rechazar automáticamente otras propuestas del mismo caso
      print(
          '🔄 SUPABASE: Rechazando otras propuestas del caso ${proposalData['case_id']}');
      print('🔍 PROPUESTA ACEPTADA ID: ${proposalData['id']} (NO se rechaza)');

      // Primero ver qué propuestas se van a rechazar
      final otherProposals = await client
          .from('proposals')
          .select('id, lawyer_id, status')
          .eq('case_id', proposalData['case_id'])
          .neq('id', proposalData['id']);

      print('🔍 PROPUESTAS QUE SE VAN A RECHAZAR: $otherProposals');

      await client
          .from('proposals')
          .update({'status': 'rejected'})
          .eq('case_id', proposalData['case_id'])
          .neq('id', proposalData['id']);

      print('✅ SUPABASE: Otras propuestas rechazadas automáticamente');

      // 6. Crear conversación entre cliente y abogado
      try {
        await client.from('conversations').insert({
          'client_id': proposalData['client_id'],
          'lawyer_id': proposalData['lawyer_id'],
          'case_id': proposalData['case_id'],
        });
        print('✅ SUPABASE: Conversación creada');
      } catch (e) {
        print(
            '⚠️ SUPABASE: Error al crear conversación (puede ya existir): $e');
        // No fallar por esto, la conversación puede ya existir
      }
    } catch (e, stackTrace) {
      print('❌ SUPABASE ERROR en _acceptProposal: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error al aceptar propuesta: $e');
    }
  }

  // ========================================
  // BÚSQUEDA DE ABOGADOS
  // ========================================

  // Buscar abogados
  static Future<List<Map<String, dynamic>>> searchLawyers({
    String? specialization,
    String? location,
    double? minRating,
    bool? verified,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = client.from('lawyer_profiles').select('*');

      // Aplicar filtros antes de ejecutar la query
      if (specialization != null && specialization != 'Todas') {
        query = query.contains('specializations',
            [specialization]); // Corregido: usar specializations (plural)
      }

      if (location != null && location != 'Nacional') {
        // Filtrar por location en la tabla user_profiles usando JOIN
        // Pero vamos a hacer esto de forma más simple - obtener todos y filtrar después
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (verified == true) {
        query = query.eq('verified', true);
      }

      final lawyerResponse = await query
          .order('rating', ascending: false)
          .range(offset, offset + limit - 1);

      // Obtener información de usuarios por separado
      final lawyerIds = lawyerResponse.map((lawyer) => lawyer['id']).toList();
      if (lawyerIds.isEmpty) return [];

      final userResponse = await client
          .from('user_profiles')
          .select('id, full_name, location, phone')
          .inFilter('id', lawyerIds);

      // Combinar los datos
      final result = <Map<String, dynamic>>[];
      for (final lawyer in lawyerResponse) {
        final userData = userResponse.firstWhere(
          (user) => user['id'] == lawyer['id'],
          orElse: () => {},
        );

        final combined = Map<String, dynamic>.from(lawyer);
        combined['user_profiles'] = userData;

        // Aplicar filtro de location si es necesario
        if (location != null &&
            location != 'Nacional' &&
            userData['location'] != location) {
          continue;
        }

        result.add(combined);
      }

      return result;
    } catch (e) {
      print('❌ Error al buscar abogados: $e');
      return [];
    }
  }

  // Obtener perfil completo del abogado
  static Future<Map<String, dynamic>?> getLawyerProfile(String lawyerId) async {
    try {
      // Primero verificar si es estudiante
      final userProfileResponse = await client
          .from('user_profiles')
          .select('user_type')
          .eq('id', lawyerId)
          .maybeSingle();

      // Si es estudiante, devolver datos básicos del perfil de usuario
      if (userProfileResponse != null &&
          userProfileResponse['user_type'] == 'student') {
        final studentProfile = await client
            .from('user_profiles')
            .select('*')
            .eq('id', lawyerId)
            .maybeSingle();

        return studentProfile;
      }

      // Si es abogado, obtener perfil completo
      final lawyerResponse = await client
          .from('lawyer_profiles')
          .select('*')
          .eq('id', lawyerId)
          .maybeSingle();

      if (lawyerResponse == null) {
        print(
            '⚠️ SUPABASE: No se encontró perfil de abogado para ID: $lawyerId');
        return null;
      }

      // Obtener datos del usuario por separado
      final userResponse = await client
          .from('user_profiles')
          .select('full_name, location, phone, email')
          .eq('id', lawyerId)
          .maybeSingle();

      // Combinar los datos
      final response = Map<String, dynamic>.from(lawyerResponse);
      if (userResponse != null) {
        response['user_profiles'] = userResponse;
      }

      return response;
    } catch (e) {
      print('❌ Error en getLawyerProfile: $e');
      return null;
    }
  }

  // Actualizar perfil del abogado
  static Future<void> updateLawyerProfile({
    required String lawyerId,
    String? licenseNumber,
    int? experienceYears,
    String? education,
    String? bio,
    double? hourlyRate,
    List<String>? specializations,
    List<String>? certifications,
    bool? isAvailable,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (licenseNumber != null) updateData['license_number'] = licenseNumber;
      if (experienceYears != null)
        updateData['experience_years'] = experienceYears;
      if (education != null) updateData['education'] = education;
      if (bio != null) updateData['bio'] = bio;
      if (hourlyRate != null) updateData['hourly_rate'] = hourlyRate;
      if (specializations != null)
        updateData['specializations'] = specializations;
      if (certifications != null) updateData['certifications'] = certifications;
      if (isAvailable != null) updateData['is_available'] = isAvailable;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      await client
          .from('lawyer_profiles')
          .update(updateData)
          .eq('id', lawyerId);

      print('✅ SUPABASE: Perfil de abogado actualizado exitosamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en updateLawyerProfile: $e');
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Actualizar horarios del abogado
  static Future<void> updateLawyerSchedule({
    required String lawyerId,
    required Map<String, dynamic> weeklySchedule,
    int? appointmentDuration,
    int? bufferTime,
    bool? allowWeekendConsultations,
    bool? allowEmergencyContacts,
    String? timezone,
    List<Map<String, dynamic>>? exceptions,
  }) async {
    try {
      final scheduleData = {
        'weekly_schedule': weeklySchedule,
        'appointment_duration': appointmentDuration,
        'buffer_time': bufferTime,
        'allow_weekend_consultations': allowWeekendConsultations,
        'allow_emergency_contacts': allowEmergencyContacts,
        'timezone': timezone,
        'exceptions': exceptions,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('lawyer_profiles')
          .update(scheduleData)
          .eq('id', lawyerId);

      print('✅ SUPABASE: Horarios de abogado actualizados exitosamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en updateLawyerSchedule: $e');
      throw Exception('Error al actualizar horarios: $e');
    }
  }

  // Actualizar preferencias de notificaciones del abogado
  static Future<void> updateLawyerNotificationSettings({
    required String lawyerId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? newCaseAlerts,
    bool? messageAlerts,
    bool? appointmentReminders,
    bool? marketingEmails,
  }) async {
    try {
      final notificationData = {
        'email_notifications': emailNotifications,
        'push_notifications': pushNotifications,
        'sms_notifications': smsNotifications,
        'new_case_alerts': newCaseAlerts,
        'message_alerts': messageAlerts,
        'appointment_reminders': appointmentReminders,
        'marketing_emails': marketingEmails,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('lawyer_profiles')
          .update(notificationData)
          .eq('id', lawyerId);

      print(
          '✅ SUPABASE: Preferencias de notificación actualizadas exitosamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en updateLawyerNotificationSettings: $e');
      throw Exception('Error al actualizar notificaciones: $e');
    }
  }

  // Actualizar configuraciones de precios del abogado
  static Future<void> updateLawyerPricingSettings({
    required String lawyerId,
    double? hourlyRate,
    double? consultationFee,
    List<Map<String, dynamic>>? servicePrices,
    String? paymentMethods,
    String? currency,
    bool? acceptPaymentPlans,
  }) async {
    try {
      final pricingData = {
        'hourly_rate': hourlyRate,
        'consultation_fee': consultationFee,
        'service_prices': servicePrices,
        'payment_methods': paymentMethods,
        'currency': currency,
        'accept_payment_plans': acceptPaymentPlans,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('lawyer_profiles')
          .update(pricingData)
          .eq('id', lawyerId);

      print('✅ SUPABASE: Configuraciones de precios actualizadas exitosamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en updateLawyerPricingSettings: $e');
      throw Exception('Error al actualizar precios: $e');
    }
  }

  // Actualizar configuraciones de privacidad del abogado
  static Future<void> updateLawyerPrivacySettings({
    required String lawyerId,
    bool? profileVisible,
    bool? showContactInfo,
    bool? allowDirectMessages,
    bool? showReviews,
    String? privacyLevel,
  }) async {
    try {
      final privacyData = {
        'profile_visible': profileVisible,
        'show_contact_info': showContactInfo,
        'allow_direct_messages': allowDirectMessages,
        'show_reviews': showReviews,
        'privacy_level': privacyLevel,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('lawyer_profiles')
          .update(privacyData)
          .eq('id', lawyerId);

      print(
          '✅ SUPABASE: Configuraciones de privacidad actualizadas exitosamente');
    } catch (e) {
      print('❌ SUPABASE ERROR en updateLawyerPrivacySettings: $e');
      throw Exception('Error al actualizar privacidad: $e');
    }
  }

  // ========================================
  // NOTIFICACIONES
  // ========================================

  // Crear notificación
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? relatedId,
  }) async {
    await client.from('notifications').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'related_id': relatedId,
    });
  }

  // Obtener notificaciones del usuario
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    bool? unreadOnly,
    int limit = 50,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return [];

      var query = client.from('notifications').select();

      // Aplicar filtros
      query = query.eq('user_id', user.id);

      if (unreadOnly == true) {
        query = query.eq('read', false);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Error al obtener notificaciones: handled silently
      return [];
    }
  }

  // Marcar notificación como leída
  static Future<void> markNotificationAsRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'read': true}).eq('id', notificationId);
  }

  // Marcar todas las notificaciones como leídas
  static Future<void> markAllNotificationsAsRead() async {
    final user = currentUser;
    if (user == null) return;

    await client
        .from('notifications')
        .update({'read': true})
        .eq('user_id', user.id)
        .eq('read', false);
  }

  // ========================================
  // UTILIDADES
  // ========================================

  // Subir archivo
  static Future<String> uploadFile({
    required String bucket,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      await client.storage
          .from(bucket)
          .uploadBinary(fileName, Uint8List.fromList(fileBytes));

      return client.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      // Error al subir archivo: handled silently
      rethrow;
    }
  }

  // Obtener URL pública de archivo
  static String getPublicUrl(String bucket, String fileName) {
    return client.storage.from(bucket).getPublicUrl(fileName);
  }

  // Escuchar cambios en tiempo real
  static RealtimeChannel subscribeToTable({
    required String table,
    required void Function(PostgresChangePayload) onData,
    PostgresChangeEvent event = PostgresChangeEvent.all,
    String? filter,
  }) {
    var channel = client.channel('public:$table');

    if (filter != null) {
      channel = channel.onPostgresChanges(
        event: event,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filter.split('=')[0],
          value: filter.split('=')[1],
        ),
        callback: onData,
      );
    } else {
      channel = channel.onPostgresChanges(
        event: event,
        schema: 'public',
        table: table,
        callback: onData,
      );
    }

    channel.subscribe();
    return channel;
  }

  // ========================================
  // SISTEMA DE MENSAJES DE CHAT
  // ========================================

  // Obtener mensajes de un caso
  static Future<List<Map<String, dynamic>>> getChatMessages(
      String caseId) async {
    try {
      final response = await client
          .from('chat_messages')
          .select('*')
          .eq('case_id', caseId)
          .order('created_at', ascending: true);

      print(
          '✅ SUPABASE: getChatMessages exitoso - ${response.length} mensajes encontrados');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ SUPABASE ERROR al obtener mensajes: $e');
      return [];
    }
  }

  // Enviar mensaje
  static Future<bool> sendChatMessage({
    required String caseId,
    required String message,
    required String senderType, // 'client' o 'lawyer'
  }) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      await client.from('chat_messages').insert({
        'case_id': caseId,
        'sender_id': user.id,
        'sender_type': senderType,
        'message': message,
      });

      print('✅ SUPABASE: Mensaje enviado exitosamente');
      return true;
    } catch (e) {
      print('❌ SUPABASE ERROR al enviar mensaje: $e');
      return false;
    }
  }

  // Marcar mensajes como leídos
  static Future<void> markMessagesAsRead(String caseId) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('case_id', caseId)
          .neq('sender_id', user.id);

      print('✅ SUPABASE: Mensajes marcados como leídos');
    } catch (e) {
      print('❌ SUPABASE ERROR al marcar mensajes como leídos: $e');
    }
  }

  // Escuchar nuevos mensajes en tiempo real
  static RealtimeChannel subscribeToMessages({
    required String caseId,
    required void Function(Map<String, dynamic>) onNewMessage,
  }) {
    return subscribeToTable(
      table: 'chat_messages',
      onData: (payload) {
        if (payload.newRecord['case_id'] == caseId) {
          onNewMessage(payload.newRecord);
        }
      },
      event: PostgresChangeEvent.insert,
    );
  }

  // Cambiar contraseña del usuario
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🔐 SUPABASE: Intentando cambiar contraseña...');

      // Cambiar contraseña usando Supabase Auth
      await client.auth.updateUser(UserAttributes(password: newPassword));

      print('✅ SUPABASE: Contraseña cambiada exitosamente');
      return true;
    } catch (e) {
      print('❌ SUPABASE ERROR en changePassword: $e');
      throw Exception('Error al cambiar contraseña: $e');
    }
  }
}
