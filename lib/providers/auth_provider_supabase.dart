import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/auth_service.dart';
import '../config/supabase_config.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.id;
  String? get userEmail => _user?.email;
  String? get userName => _userProfile?['full_name'];
  String? get userType => _userProfile?['user_type'];
  String? get userLocation => _userProfile?['location'];
  String? get userPhone => _userProfile?['phone'];
  String? get userAvatar => _userProfile?['avatar_url'];
  
  // Verificaciones de tipo
  bool get isLawyer => userType == 'lawyer';
  bool get isClient => userType == 'client';
  bool get isStudent => userType == 'student';
  bool get needsEmailVerification => _user?.emailConfirmedAt == null;
  
  AuthProvider() {
    _initialize();
  }
  
  // Inicializar y escuchar cambios de autenticación
  void _initialize() {
    // Usuario actual
    _user = AuthService.currentUser;
    
    // Cargar perfil si hay usuario
    if (_user != null) {
      _loadUserProfile();
    }
    
    // Escuchar cambios de autenticación
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      
      if (_user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      
      notifyListeners();
    });
  }
  
  // ========================================
  // AUTENTICACIÓN
  // ========================================
  
  // Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.signIn(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        _user = result.user;
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error de autenticación');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Registro de cliente
  Future<bool> registerClient({
    required String email,
    required String password,
    required String fullName,
    required String documentType,
    required String documentNumber,
    String? phone,
    String? location,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.registerClient(
        email: email,
        password: password,
        fullName: fullName,
        documentType: documentType,
        documentNumber: documentNumber,
        phone: phone,
        location: location,
      );
      
      if (result.isSuccess) {
        _user = result.user;
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error en el registro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Registro de abogado
  Future<bool> registerLawyer({
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
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.registerLawyer(
        email: email,
        password: password,
        fullName: fullName,
        documentType: documentType,
        documentNumber: documentNumber,
        licenseNumber: licenseNumber,
        specialization: specialization,
        experienceYears: experienceYears,
        phone: phone,
        location: location,
        education: education,
        bio: bio,
      );
      
      if (result.isSuccess) {
        _user = result.user;
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error en el registro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Registro de estudiante de derecho
  Future<bool> registerStudent({
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
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.registerStudent(
        email: email,
        password: password,
        fullName: fullName,
        documentType: documentType,
        documentNumber: documentNumber,
        university: university,
        semester: semester,
        phone: phone,
        location: location,
        documentPath: documentPath,
      );
      
      if (result.isSuccess) {
        _user = result.user;
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error en el registro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await AuthService.signOut();
      _user = null;
      _userProfile = null;
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    }
    
    _setLoading(false);
  }
  
  // ========================================
  // GESTIÓN DE PERFIL
  // ========================================
  
  // Cargar perfil de usuario
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      print('🔍 AuthProvider: Cargando perfil para usuario ${_user!.id}');
      _userProfile = await AuthService.getCurrentUserProfile();
      
      // Si no hay perfil, intentar crearlo con datos básicos del usuario
      if (_userProfile == null) {
        print('⚠️ AuthProvider: Perfil no encontrado, creando perfil básico...');
        final userData = _user!.userMetadata;
        final userType = userData?['user_type'] ?? 'client';
        final fullName = userData?['full_name'] ?? _user!.email?.split('@')[0] ?? 'Usuario';
        
        print('📝 AuthProvider: Creando perfil - Tipo: $userType, Nombre: $fullName');
        
        // Crear perfil básico
        await AuthService.createBasicProfile(
          userId: _user!.id,
          email: _user!.email!,
          fullName: fullName,
          userType: userType,
        );
        
        // Recargar perfil
        _userProfile = await AuthService.getCurrentUserProfile();
        
        if (_userProfile != null) {
          print('✅ AuthProvider: Perfil creado exitosamente');
        } else {
          print('❌ AuthProvider: Error - No se pudo crear el perfil');
        }
      } else {
        print('✅ AuthProvider: Perfil cargado exitosamente - Tipo: ${_userProfile!['user_type']}');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ AuthProvider: Error cargando perfil: $e');
      // Si hay error, crear un perfil temporal para evitar que se quede bloqueado
      _userProfile = {
        'id': _user!.id,
        'email': _user!.email,
        'full_name': _user!.userMetadata?['full_name'] ?? 'Usuario',
        'user_type': _user!.userMetadata?['user_type'] ?? 'client',
      };
      notifyListeners();
    }
  }
  
  // Recargar perfil
  Future<void> reloadProfile() async {
    await _loadUserProfile();
  }
  
  // Actualizar perfil
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? location,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.updateProfile(
        fullName: fullName,
        phone: phone,
        location: location,
        avatarUrl: avatarUrl,
      );
      
      if (result.isSuccess) {
        await _loadUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error actualizando perfil');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // ========================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ========================================
  
  // Solicitar recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.resetPassword(email);
      
      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error enviando email de recuperación');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Actualizar contraseña
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.updatePassword(newPassword);
      
      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error actualizando contraseña');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // ========================================
  // VERIFICACIÓN DE EMAIL
  // ========================================
  
  // Reenviar email de verificación
  Future<bool> resendEmailVerification() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await AuthService.resendEmailVerification();
      
      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Error reenviando verificación');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Limpiar errores manualmente
  void clearError() {
    _clearError();
  }
}
