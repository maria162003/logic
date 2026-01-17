import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  static SupabaseClient get _client => SupabaseConfig.client;
  
  // Estado de autenticación
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static String? get currentUserId => currentUser?.id;
  
  // Stream de cambios de autenticación  
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // ========================================
  // VALIDACIONES DE DUPLICADOS
  // ========================================
  
  // Verificar si ya existe un usuario con el mismo email o documento
  static Future<Map<String, bool>> checkForDuplicates({
    required String email,
    required String documentType,
    required String documentNumber,
  }) async {
    try {
      // Verificar email duplicado
      final emailExists = await _client
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      // Verificar documento duplicado
      final documentExists = await _client
          .from('user_profiles')
          .select('id')
          .eq('document_type', documentType)
          .eq('document_number', documentNumber)
          .maybeSingle();
      
      return {
        'emailExists': emailExists != null,
        'documentExists': documentExists != null,
      };
    } catch (e) {
      print('❌ AuthService: Error verificando duplicados: $e');
      throw Exception('Error verificando datos existentes');
    }
  }

  // ========================================
  // REGISTRO DE USUARIOS
  // ========================================
  
  // Registro de cliente
  static Future<AuthResult> registerClient({
    required String email,
    required String password,
    required String fullName,
    required String documentType,
    required String documentNumber,
    String? phone,
    String? location,
  }) async {
    try {
      // Verificar duplicados antes de crear el usuario
      final duplicates = await checkForDuplicates(
        email: email,
        documentType: documentType,
        documentNumber: documentNumber,
      );
      
      if (duplicates['emailExists'] == true) {
        return AuthResult.error('Ya existe un usuario registrado con este correo electrónico');
      }
      
      if (duplicates['documentExists'] == true) {
        return AuthResult.error('Ya existe un usuario registrado con este número de documento');
      }
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': 'client',
          'phone': phone,
          'location': location,
        },
      );
      
      if (response.user != null) {
        // Intentar crear perfil de cliente (sin fallar si hay problemas de permisos)
        try {
          await _createUserProfile(
            userId: response.user!.id,
            email: email,
            fullName: fullName,
            userType: 'client',
            phone: phone,
            location: location,
            documentType: documentType,
            documentNumber: documentNumber,
          );
        } catch (e) {
          // Error al crear perfil ignorado - el usuario puede usar la app
          print('Profile creation failed (will be created later): $e');
        }
        
        return AuthResult.success(response.user!);
      }
      
      return AuthResult.error('Error al crear usuario');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  // Registro de abogado
  static Future<AuthResult> registerLawyer({
    required String email,
    required String password,
    required String fullName,
    required String documentType,
    required String documentNumber,
    required String licenseNumber,
    required List<String> specialization,
    required int experienceYears,
    String? phone,
    String? location,
    String? education,
    String? bio,
  }) async {
    try {
      // Verificar duplicados antes de crear el usuario
      final duplicates = await checkForDuplicates(
        email: email,
        documentType: documentType,
        documentNumber: documentNumber,
      );
      
      if (duplicates['emailExists'] == true) {
        return AuthResult.error('Ya existe un usuario registrado con este correo electrónico');
      }
      
      if (duplicates['documentExists'] == true) {
        return AuthResult.error('Ya existe un usuario registrado con este número de documento');
      }
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': 'lawyer',
          'phone': phone,
          'location': location,
        },
      );
      
      if (response.user != null) {
        // Intentar crear perfil base (sin fallar si hay problemas de permisos)
        try {
          await _createUserProfile(
            userId: response.user!.id,
            email: email,
            fullName: fullName,
            userType: 'lawyer',
            phone: phone,
            location: location,
            documentType: documentType,
            documentNumber: documentNumber,
          );
          
          // Crear perfil de abogado
          await _createLawyerProfile(
            userId: response.user!.id,
            licenseNumber: licenseNumber,
            specialization: specialization,
            experienceYears: experienceYears,
            education: education,
            bio: bio,
          );
        } catch (e) {
          // Error al crear perfil ignorado - el usuario puede usar la app
          print('Profile creation failed (will be created later): $e');
        }
        
        return AuthResult.success(response.user!);
      }
      
      return AuthResult.error('Error al crear usuario');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  // Registro de estudiante de derecho
  static Future<AuthResult> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String documentType,
    required String documentNumber,
    required String university,
    required int semester,
    String? phone,
    String? location,
    String? documentPath,
  }) async {
    try {
      // Verificar duplicados antes de crear el usuario
      final duplicates = await checkForDuplicates(
        email: email,
        documentType: documentType,
        documentNumber: documentNumber,
      );
      
      if (duplicates['emailExists'] == true) {
        return AuthResult.error('Ya existe un usuario registrado con este correo electrónico');
      }
      
      if (duplicates['documentExists'] == true) {
        return AuthResult.error('Ya existe un usuario registrado con este número de documento');
      }
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': 'student',
          'phone': phone,
          'location': location,
        },
      );
      
      if (response.user != null) {
        // Intentar crear perfil base (sin fallar si hay problemas de permisos)
        try {
          await _createUserProfile(
            userId: response.user!.id,
            email: email,
            fullName: fullName,
            userType: 'student',
            phone: phone,
            location: location,
            documentType: documentType,
            documentNumber: documentNumber,
          );
          
          // Crear perfil de estudiante
          await _createStudentProfile(
            userId: response.user!.id,
            university: university,
            semester: semester,
            documentPath: documentPath,
          );
        } catch (e) {
          // Error al crear perfil ignorado - el usuario puede usar la app
          print('Profile creation failed (will be created later): $e');
        }
        
        return AuthResult.success(response.user!);
      }
      
      return AuthResult.error('Error al crear usuario');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // ========================================
  // INICIO DE SESIÓN
  // ========================================
  
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return AuthResult.success(response.user!);
      }
      
      return AuthResult.error('Credenciales inválidas');
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e.toString()));
    }
  }
  
  // ========================================
  // GESTIÓN DE SESIÓN
  // ========================================
  
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Verificar si el usuario necesita verificar email
  static bool get needsEmailVerification {
    final user = currentUser;
    return user != null && user.emailConfirmedAt == null;
  }
  
  // Reenviar email de verificación
  static Future<AuthResult> resendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.error('Usuario no encontrado');
      }
      
      await _client.auth.resend(
        type: OtpType.signup,
        email: user.email!,
      );
      
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  // ========================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ========================================
  
  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  // Actualizar contraseña
  static Future<AuthResult> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (response.user != null) {
        return AuthResult.success(response.user!);
      }
      
      return AuthResult.error('Error al actualizar contraseña');
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  // ========================================
  // PERFIL DE USUARIO
  // ========================================
  
  // Obtener perfil completo del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      print('❌ AuthService: No hay usuario autenticado');
      return null;
    }
    
    try {
      print('🔍 AuthService: Buscando perfil para usuario ${user.id}');
      final profile = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (profile != null) {
        print('✅ AuthService: Perfil encontrado - Tipo: ${profile['user_type']}');
      } else {
        print('⚠️ AuthService: No se encontró perfil para el usuario');
      }
      
      return profile;
    } catch (e) {
      print('❌ AuthService: Error obteniendo perfil: $e');
      return null;
    }
  }
  
  // Obtener tipo de usuario
  static Future<String?> getUserType() async {
    final profile = await getCurrentUserProfile();
    return profile?['user_type'];
  }
  
  // Verificar si es abogado
  static Future<bool> isLawyer() async {
    final userType = await getUserType();
    return userType == 'lawyer';
  }
  
  // Verificar si es cliente
  static Future<bool> isClient() async {
    final userType = await getUserType();
    return userType == 'client';
  }
  
  // Actualizar perfil
  static Future<AuthResult> updateProfile({
    String? fullName,
    String? phone,
    String? location,
    String? avatarUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.error('Usuario no autenticado');
      }
      
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;
      if (avatarUrl != null) updates['profile_image_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id);
      
      // Actualizar metadata del usuario si es necesario
      if (fullName != null) {
        await _client.auth.updateUser(
          UserAttributes(data: {'full_name': fullName}),
        );
      }
      
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  // ========================================
  // MÉTODOS PÚBLICOS PARA PERFILES
  // ========================================
  
  // Crear perfil básico (método público)
  static Future<void> createBasicProfile({
    required String userId,
    required String email,
    required String fullName,
    required String userType,
    String? phone,
    String? location,
  }) async {
    await _createUserProfile(
      userId: userId,
      email: email,
      fullName: fullName,
      userType: userType,
      phone: phone,
      location: location,
    );
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================
  
  // Crear perfil base
  static Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String userType,
    String? phone,
    String? location,
    String? documentType,
    String? documentNumber,
  }) async {
    try {
      print('📝 AuthService: Creando perfil para usuario $userId');
      await _client.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'user_type': userType,
        'phone': phone,
        'location': location,
        'document_type': documentType,
        'document_number': documentNumber,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ AuthService: Perfil creado exitosamente');
    } catch (e) {
      print('❌ AuthService: Error creando perfil: $e');
      throw e;
    }
  }
  
  // Crear perfil específico de abogado
  static Future<void> _createLawyerProfile({
    required String userId,
    required String licenseNumber,
    required List<String> specialization,
    required int experienceYears,
    String? education,
    String? bio,
  }) async {
    await _client.from('lawyers').insert({
      'id': userId,
      'license_number': licenseNumber,
      'specializations': specialization, // Corregido: usar specializations (plural)
      'experience_years': experienceYears,
      'education': education,
      'bio': bio,
      'verified': false, // Se verificará posteriormente
      'rating': 0.0,
      'total_reviews': 0,
    });
  }
  
  // Crear perfil específico de estudiante
  static Future<void> _createStudentProfile({
    required String userId,
    required String university,
    required int semester,
    String? documentPath,
  }) async {
    // Actualizar el perfil de usuario con los campos de estudiante
    await _client.from('user_profiles').update({
      'universidad': university,
      'semestre_actual': semester,
      'archivo_constancia': documentPath,
      // No usar 'role' porque esa columna no existe
      // El user_type ya se estableció como 'student' en la creación del perfil base
    }).eq('id', userId);
  }
  
  // Obtener mensaje de error amigable
  static String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos';
    } else if (error.contains('User already registered')) {
      return 'El usuario ya está registrado';
    } else if (error.contains('Email not confirmed')) {
      return 'Por favor confirma tu email antes de iniciar sesión';
    } else if (error.contains('Invalid email')) {
      return 'Email inválido';
    } else if (error.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    } else if (error.contains('Network request failed')) {
      return 'Error de conexión. Verifica tu internet';
    }
    
    return 'Error de autenticación: $error';
  }
}

// ========================================
// CLASE DE RESULTADO
// ========================================

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  
  const AuthResult._(this.success, this.error, this.user);
  
  factory AuthResult.success(User? user) => AuthResult._(true, null, user);
  factory AuthResult.error(String error) => AuthResult._(false, error, null);
  
  bool get isSuccess => success;
  bool get isError => !success;
}

// ========================================
// ESTADOS DE AUTENTICACIÓN
// ========================================

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  emailNotVerified,
}
