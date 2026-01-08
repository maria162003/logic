import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MembershipType { basic, premium }

class UserConfigProvider extends ChangeNotifier {
  // Configuraciones del usuario
  String _selectedLanguage = 'Español';
  String _selectedRegion = 'Bogotá, Colombia';
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  MembershipType _membershipType = MembershipType.basic;
  DateTime? _premiumExpiryDate;
  
  // Información del perfil
  String _fullName = '';
  String _phone = '';
  String _address = '';
  String _documentNumber = '';

  // Getters
  String get selectedLanguage => _selectedLanguage;
  String get selectedRegion => _selectedRegion;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  bool get darkMode => _darkMode;
  MembershipType get membershipType => _membershipType;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  String get fullName => _fullName;
  String get phone => _phone;
  String get address => _address;
  String get documentNumber => _documentNumber;
  String get idNumber => _documentNumber; // Alias para compatibilidad

  bool get isPremium {
    if (_membershipType == MembershipType.basic) return false;
    if (_premiumExpiryDate == null) return true; // Premium sin expiración
    return _premiumExpiryDate!.isAfter(DateTime.now());
  }

  String get membershipDisplayName {
    switch (_membershipType) {
      case MembershipType.basic:
        return 'Cliente Básico';
      case MembershipType.premium:
        return 'Cliente Premium';
    }
  }

  String get membershipStatusText {
    if (_membershipType == MembershipType.basic) {
      return 'Actualiza a Premium para más beneficios';
    }
    if (_premiumExpiryDate == null) {
      return 'Premium de por vida';
    }
    final daysLeft = _premiumExpiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft > 30) {
      return 'Premium activo';
    } else if (daysLeft > 0) {
      return 'Premium - Expira en $daysLeft días';
    } else {
      return 'Premium expirado';
    }
  }

  // Inicializar configuraciones desde SharedPreferences
  Future<void> loadUserConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _selectedLanguage = prefs.getString('language') ?? 'Español';
      _selectedRegion = prefs.getString('region') ?? 'Bogotá, Colombia';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      
      // Cargar membresía
      final membershipStr = prefs.getString('membership_type') ?? 'basic';
      _membershipType = membershipStr == 'premium' ? MembershipType.premium : MembershipType.basic;
      
      final expiryStr = prefs.getString('premium_expiry');
      if (expiryStr != null) {
        _premiumExpiryDate = DateTime.parse(expiryStr);
      }

      // Cargar información del perfil
      _fullName = prefs.getString('full_name') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _address = prefs.getString('address') ?? '';
      _documentNumber = prefs.getString('document_number') ?? '';

      notifyListeners();
    } catch (e) {
      print('Error cargando configuración: $e');
    }
  }

  // Guardar configuraciones
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _selectedLanguage);
      await prefs.setString('region', _selectedRegion);
      await prefs.setBool('notifications', _notificationsEnabled);
      await prefs.setBool('email_notifications', _emailNotifications);
      await prefs.setBool('push_notifications', _pushNotifications);
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setString('membership_type', _membershipType.toString().split('.').last);
      
      if (_premiumExpiryDate != null) {
        await prefs.setString('premium_expiry', _premiumExpiryDate!.toIso8601String());
      }

      await prefs.setString('full_name', _fullName);
      await prefs.setString('phone', _phone);
      await prefs.setString('address', _address);
      await prefs.setString('document_number', _documentNumber);
    } catch (e) {
      print('Error guardando configuración: $e');
    }
  }

  // Setters con persistencia
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> setRegion(String region) async {
    _selectedRegion = region;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> setEmailNotifications(bool enabled) async {
    _emailNotifications = enabled;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> setPushNotifications(bool enabled) async {
    _pushNotifications = enabled;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    notifyListeners();
    await _saveConfig();
  }

  // Función para actualizar información personal
  Future<void> setPersonalInfo({
    required String fullName,
    required String phone,
    required String address,
    required String idNumber,
  }) async {
    _fullName = fullName;
    _phone = phone;
    _address = address;
    _documentNumber = idNumber;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String address,
    required String documentNumber,
  }) async {
    _fullName = fullName;
    _phone = phone;
    _address = address;
    _documentNumber = documentNumber;
    notifyListeners();
    await _saveConfig();
  }

  // Funciones de membresía
  Future<void> upgradeToPremium({DateTime? expiryDate}) async {
    _membershipType = MembershipType.premium;
    _premiumExpiryDate = expiryDate;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> downgradeToBasic() async {
    _membershipType = MembershipType.basic;
    _premiumExpiryDate = null;
    notifyListeners();
    await _saveConfig();
  }

  // Función para activar Premium temporal (para demo)
  Future<void> activateTrialPremium() async {
    _membershipType = MembershipType.premium;
    _premiumExpiryDate = DateTime.now().add(const Duration(days: 30));
    notifyListeners();
    await _saveConfig();
  }

  // Beneficios Premium
  List<String> get premiumBenefits => [
    'Consultas ilimitadas con abogados',
    'Prioridad en respuestas (24h máximo)',
    'Acceso a chat legal con IA avanzada',
    'Descuentos especiales en servicios',
    'Soporte telefónico directo',
    'Almacenamiento ilimitado de documentos',
    'Notificaciones personalizadas',
    'Acceso anticipado a nuevas funciones'
  ];

  List<String> get basicLimitations => [
    'Máximo 3 consultas por mes',
    'Tiempo de respuesta: 48-72h',
    'Chat básico con IA',
    'Sin descuentos especiales',
    'Solo soporte por email',
    'Máximo 10 documentos',
    'Notificaciones estándar'
  ];
}