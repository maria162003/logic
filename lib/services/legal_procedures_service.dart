import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para manejar trámites jurídicos con estudiantes de derecho
class LegalProceduresService {
  static SupabaseClient get _client => Supabase.instance.client;
  static User? get currentUser => _client.auth.currentUser;

  // ========================================
  // TIPOS DE TRÁMITES
  // ========================================
  
  static const Map<String, Map<String, String>> procedureTypes = {
    'contratos': {
      'title': 'Contratos',
      'category': 'borradores_textos',
      'description': 'Elaboración de borradores de contratos civiles y comerciales',
    },
    'tutelas': {
      'title': 'Tutelas y/o derechos de petición',
      'category': 'borradores_textos',
      'description': 'Redacción de tutelas y derechos de petición',
    },
    'poderes': {
      'title': 'Poderes',
      'category': 'borradores_textos',
      'description': 'Elaboración de borradores de poderes',
    },
    'radicacion': {
      'title': 'Radicación de documentos',
      'category': 'tramites_juridicos',
      'description': 'Radicación de documentos ante juzgados o entidades públicas',
    },
    'certificados': {
      'title': 'Solicitud de certificados',
      'category': 'tramites_juridicos',
      'description': 'Gestión de solicitud de certificados legales',
    },
    'conceptos': {
      'title': 'Conceptos jurídicos',
      'category': 'conceptos_juridicos',
      'description': 'Conceptos con respecto a situaciones que involucran derechos',
    },
  };

  // ========================================
  // CREAR TRÁMITE (CLIENTE)
  // ========================================
  
  static Future<Map<String, dynamic>?> createProcedure({
    required String procedureType,
    required String title,
    required String description,
    String urgency = 'normal',
    DateTime? deadline,
    Map<String, dynamic>? additionalInfo,
    List<String>? documents,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final typeInfo = procedureTypes[procedureType];
      if (typeInfo == null) throw Exception('Tipo de trámite no válido');

      final data = {
        'client_id': user.id,
        'procedure_type': procedureType,
        'procedure_category': typeInfo['category'],
        'title': title,
        'description': description,
        'urgency': urgency,
        'deadline': deadline?.toIso8601String(),
        'additional_info': additionalInfo ?? {},
        'documents': documents ?? [],
        'status': 'pending',
      };

      final response = await _client
          .from('legal_procedures')
          .insert(data)
          .select()
          .single();

      print('✅ Trámite creado: ${response['id']}');
      return response;
    } catch (e) {
      print('❌ Error al crear trámite: $e');
      rethrow;
    }
  }

  // ========================================
  // OBTENER TRÁMITES DEL CLIENTE
  // ========================================
  
  static Future<List<Map<String, dynamic>>> getClientProcedures() async {
    try {
      final user = currentUser;
      if (user == null) return [];

      final response = await _client
          .from('legal_procedures')
          .select('''
            *,
            student:student_id(id, full_name, profile_image_url),
            proposals:procedure_proposals(count)
          ''')
          .eq('client_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error al obtener trámites del cliente: $e');
      return [];
    }
  }

  // ========================================
  // OBTENER TRÁMITES DISPONIBLES (ESTUDIANTE)
  // ========================================
  
  static Future<List<Map<String, dynamic>>> getAvailableProcedures() async {
    try {
      final user = currentUser;
      if (user == null) return [];

      // Verificar que el estudiante esté verificado
      final isVerified = await isStudentVerified();
      if (!isVerified) {
        print('⚠️ Estudiante no verificado');
        return [];
      }

      final response = await _client
          .from('legal_procedures')
          .select('''
            *,
            client:client_id(id, full_name)
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error al obtener trámites disponibles: $e');
      return [];
    }
  }

  // ========================================
  // OBTENER TRÁMITES ASIGNADOS (ESTUDIANTE)
  // ========================================
  
  static Future<List<Map<String, dynamic>>> getStudentProcedures() async {
    try {
      final user = currentUser;
      if (user == null) return [];

      final response = await _client
          .from('legal_procedures')
          .select('''
            *,
            client:client_id(id, full_name, profile_image_url)
          ''')
          .eq('student_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error al obtener trámites del estudiante: $e');
      return [];
    }
  }

  // ========================================
  // ENVIAR PROPUESTA (ESTUDIANTE)
  // ========================================
  
  static Future<void> sendProposal({
    required String procedureId,
    required String clientId,
    required String message,
    double? proposedFee,
    int estimatedDays = 7,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await _client.from('procedure_proposals').insert({
        'procedure_id': procedureId,
        'student_id': user.id,
        'client_id': clientId,
        'message': message,
        'proposed_fee': proposedFee,
        'estimated_days': estimatedDays,
        'status': 'pending',
      });

      print('✅ Propuesta enviada');
    } catch (e) {
      print('❌ Error al enviar propuesta: $e');
      rethrow;
    }
  }

  // ========================================
  // ACEPTAR PROPUESTA (CLIENTE)
  // ========================================
  
  static Future<void> acceptProposal(String proposalId, String procedureId) async {
    try {
      // Obtener datos de la propuesta
      final proposal = await _client
          .from('procedure_proposals')
          .select('*')
          .eq('id', proposalId)
          .single();

      // Actualizar propuesta a aceptada
      await _client
          .from('procedure_proposals')
          .update({'status': 'accepted'})
          .eq('id', proposalId);

      // Asignar estudiante al trámite
      await _client.from('legal_procedures').update({
        'student_id': proposal['student_id'],
        'status': 'in_progress',
      }).eq('id', procedureId);

      // Rechazar otras propuestas
      await _client
          .from('procedure_proposals')
          .update({'status': 'rejected'})
          .eq('procedure_id', procedureId)
          .neq('id', proposalId);

      print('✅ Propuesta aceptada y estudiante asignado');
    } catch (e) {
      print('❌ Error al aceptar propuesta: $e');
      rethrow;
    }
  }

  // ========================================
  // RECHAZAR PROPUESTA (CLIENTE)
  // ========================================
  
  static Future<void> rejectProposal(String proposalId) async {
    try {
      await _client
          .from('procedure_proposals')
          .update({'status': 'rejected'})
          .eq('id', proposalId);

      print('✅ Propuesta rechazada');
    } catch (e) {
      print('❌ Error al rechazar propuesta: $e');
      rethrow;
    }
  }

  // ========================================
  // OBTENER PROPUESTAS PARA UN TRÁMITE
  // ========================================
  
  static Future<List<Map<String, dynamic>>> getProcedureProposals(String procedureId) async {
    try {
      final response = await _client
          .from('procedure_proposals')
          .select('''
            *,
            student:student_id(id, full_name, profile_image_url, location),
            verification:student_id(
              student_verifications(university_name, current_semester)
            )
          ''')
          .eq('procedure_id', procedureId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error al obtener propuestas: $e');
      return [];
    }
  }

  // ========================================
  // VERIFICACIÓN DE ESTUDIANTE
  // ========================================
  
  static Future<bool> isStudentVerified() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _client
          .from('student_verifications')
          .select('verification_status')
          .eq('user_id', user.id)
          .maybeSingle();

      return response?['verification_status'] == 'verified';
    } catch (e) {
      print('❌ Error al verificar estudiante: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getStudentVerification() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('student_verifications')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error al obtener verificación: $e');
      return null;
    }
  }

  static Future<void> submitStudentVerification({
    required String universityName,
    required String studentIdNumber,
    required int currentSemester,
    String? lawSchoolName,
    String? studentCardUrl,
    String? enrollmentCertificateUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await _client.from('student_verifications').upsert({
        'user_id': user.id,
        'university_name': universityName,
        'student_id_number': studentIdNumber,
        'current_semester': currentSemester,
        'law_school_name': lawSchoolName,
        'student_card_url': studentCardUrl,
        'enrollment_certificate_url': enrollmentCertificateUrl,
        'verification_status': 'pending',
      });

      print('✅ Verificación enviada');
    } catch (e) {
      print('❌ Error al enviar verificación: $e');
      rethrow;
    }
  }

  // ========================================
  // MENSAJES DEL TRÁMITE
  // ========================================
  
  static Future<List<Map<String, dynamic>>> getProcedureMessages(String procedureId) async {
    try {
      final response = await _client
          .from('procedure_messages')
          .select('''
            *,
            sender:sender_id(id, full_name, profile_image_url)
          ''')
          .eq('procedure_id', procedureId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error al obtener mensajes: $e');
      return [];
    }
  }

  static Future<void> sendProcedureMessage({
    required String procedureId,
    required String message,
    List<String>? attachments,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await _client.from('procedure_messages').insert({
        'procedure_id': procedureId,
        'sender_id': user.id,
        'message': message,
        'attachments': attachments ?? [],
      });

      print('✅ Mensaje enviado');
    } catch (e) {
      print('❌ Error al enviar mensaje: $e');
      rethrow;
    }
  }

  // ========================================
  // ENTREGABLES
  // ========================================
  
  static Future<void> submitDeliverable({
    required String procedureId,
    required String title,
    required String fileUrl,
    String? description,
    String? fileType,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await _client.from('procedure_deliverables').insert({
        'procedure_id': procedureId,
        'student_id': user.id,
        'title': title,
        'description': description,
        'file_url': fileUrl,
        'file_type': fileType,
        'review_status': 'pending',
      });

      print('✅ Entregable enviado');
    } catch (e) {
      print('❌ Error al enviar entregable: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getProcedureDeliverables(String procedureId) async {
    try {
      final response = await _client
          .from('procedure_deliverables')
          .select('*')
          .eq('procedure_id', procedureId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error al obtener entregables: $e');
      return [];
    }
  }

  static Future<void> reviewDeliverable({
    required String deliverableId,
    required String reviewStatus, // 'approved' o 'needs_revision'
    String? revisionNotes,
  }) async {
    try {
      await _client.from('procedure_deliverables').update({
        'review_status': reviewStatus,
        'revision_notes': revisionNotes,
      }).eq('id', deliverableId);

      print('✅ Entregable revisado');
    } catch (e) {
      print('❌ Error al revisar entregable: $e');
      rethrow;
    }
  }

  // ========================================
  // ACTUALIZAR ESTADO DEL TRÁMITE
  // ========================================
  
  static Future<void> updateProcedureStatus({
    required String procedureId,
    required String status,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status};
      
      if (status == 'completed') {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _client
          .from('legal_procedures')
          .update(updateData)
          .eq('id', procedureId);

      print('✅ Estado actualizado a: $status');
    } catch (e) {
      print('❌ Error al actualizar estado: $e');
      rethrow;
    }
  }
}
