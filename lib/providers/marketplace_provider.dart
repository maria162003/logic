import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _marketplaceCases = [];
  List<Map<String, dynamic>> _myProposals = [];
  List<Map<String, dynamic>> _receivedProposals = [];
  List<Map<String, dynamic>> _myCases = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Filtros
  String _selectedCategory = 'Todas';
  String _selectedLocation = 'Nacional';
  
  // Getters
  List<Map<String, dynamic>> get marketplaceCases => _marketplaceCases;
  List<Map<String, dynamic>> get myProposals => _myProposals;
  List<Map<String, dynamic>> get receivedProposals => _receivedProposals;
  List<Map<String, dynamic>> get myCases => _myCases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;
  
  // Categorías disponibles
  static const List<String> categories = [
    'Todas',
    'Civil',
    'Penal',
    'Laboral',
    'Familiar',
    'Comercial',
    'Administrativo',
    'Constitucional',
    'Tributario',
    'Ambiental',
    'Tecnológico',
  ];
  
  // Ubicaciones disponibles
  static const List<String> locations = [
    'Nacional',
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
    'Ibagué',
    'Cúcuta',
    'Villavicencio',
    'Manizales',
    'Neiva',
    'Armenia',
    'Pasto',
    'Montería',
    'Valledupar',
    'Sincelejo',
    'Popayán',
  ];
  
  // ========================================
  // CASOS DEL MARKETPLACE
  // ========================================
  
  // Cargar casos del marketplace
  Future<void> loadMarketplaceCases({bool refresh = false, bool isStudent = false}) async {
    if (!refresh && _marketplaceCases.isNotEmpty) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final cases = await SupabaseService.getMarketplaceCases(
        category: _selectedCategory == 'Todas' ? null : _selectedCategory,
        location: _selectedLocation == 'Nacional' ? null : _selectedLocation,
        limit: 50,
        isStudent: isStudent,
      );
      
      _marketplaceCases = cases;
      _setLoading(false);
    } catch (e) {
      _setError('Error cargando casos: $e');
      _setLoading(false);
    }
  }
  
  // Filtrar casos
  Future<void> filterCases({
    String? category,
    String? location,
    bool isStudent = false,
  }) async {
    if (category != null) _selectedCategory = category;
    if (location != null) _selectedLocation = location;
    
    await loadMarketplaceCases(refresh: true, isStudent: isStudent);
  }
  
  // Crear nuevo caso
  Future<bool> createCase({
    required String title,
    required String description,
    required String category,
    double? budget,
    String? location,
    String urgency = 'medium',
    DateTime? deadline,
    List<String>? documents,
  }) async {
    print('🔍 MARKETPLACE PROVIDER: Iniciando createCase...');
    print('   - Título: $title');
    print('   - Categoría: $category');
    
    _setLoading(true);
    _clearError();
    
    try {
      print('🚀 MARKETPLACE PROVIDER: Llamando a SupabaseService.createMarketplaceCase...');
      await SupabaseService.createMarketplaceCase(
        title: title,
        description: description,
        category: category,
        budget: budget,
        location: location,
        urgency: urgency,
        deadline: deadline,
        documents: documents,
      );
      
      print('✅ MARKETPLACE PROVIDER: Caso creado en Supabase exitosamente');
      
      // Recargar casos del cliente
      print('🔄 MARKETPLACE PROVIDER: Recargando casos del cliente...');
      await loadMyCases(refresh: true);
      
      _setLoading(false);
      print('✅ MARKETPLACE PROVIDER: createCase completado exitosamente');
      return true;
    } catch (e) {
      print('❌ MARKETPLACE PROVIDER: Error en createCase: $e');
      _setError('Error creando caso: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // ========================================
  // CASOS DEL CLIENTE
  // ========================================
  
  // Cargar mis casos (cliente)
  Future<void> loadMyCases({bool refresh = false}) async {
    if (!refresh && _myCases.isNotEmpty) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final cases = await SupabaseService.getClientCases();
      _myCases = cases;
      _setLoading(false);
    } catch (e) {
      _setError('Error cargando mis casos: $e');
      _setLoading(false);
    }
  }
  
  // ========================================
  // SISTEMA DE PROPUESTAS
  // ========================================
  
  // Enviar propuesta (abogado)
  Future<bool> sendProposal({
    required String caseId,
    required String message,
    required double proposedFee,
    required int estimatedDays,
    String? paymentMethod,
    Map<String, dynamic>? proposalDetails,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      print('🔄 Enviando propuesta...');
      print('📄 Case ID: $caseId');
      print('💬 Message: $message');
      print('💰 Fee: $proposedFee');
      print('📅 Days: $estimatedDays');
      print('💳 Payment Method: $paymentMethod');
      
      await SupabaseService.sendProposal(
        caseId: caseId,
        message: message,
        proposedFee: proposedFee,
        estimatedDays: estimatedDays,
        paymentMethod: paymentMethod,
        proposalDetails: proposalDetails,
      );
      
      print('✅ Propuesta enviada correctamente');
      
      // Recargar propuestas del abogado
      await loadMyProposals(refresh: true);
      
      print('✅ Propuestas recargadas');
      
      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ Error enviando propuesta: $e');
      _setError('Error enviando propuesta: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Cargar mis propuestas (abogado)
  Future<void> loadMyProposals({bool refresh = false}) async {
    if (!refresh && _myProposals.isNotEmpty) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final proposals = await SupabaseService.getLawyerProposals();
      _myProposals = proposals;
      _setLoading(false);
    } catch (e) {
      _setError('Error cargando mis propuestas: $e');
      _setLoading(false);
    }
  }
  
  // Cargar propuestas recibidas (cliente)
  Future<void> loadReceivedProposals({bool refresh = false}) async {
    if (!refresh && _receivedProposals.isNotEmpty) return;
    
    // Use Future.microtask to avoid setState during build
    await Future.microtask(() {
      _setLoading(true);
      _clearError();
    });
    
    try {
      final proposals = await SupabaseService.getClientProposals();
      _receivedProposals = proposals;
      _setLoading(false);
    } catch (e) {
      _setError('Error cargando propuestas recibidas: $e');
      _setLoading(false);
    }
  }
  
  // Actualizar estado de propuesta
  Future<bool> updateProposalStatus({
    required String proposalId,
    required String status, // 'accepted', 'rejected', 'withdrawn'
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await SupabaseService.updateProposalStatus(
        proposalId: proposalId,
        status: status,
      );
      
      // Recargar propuestas según el contexto
      if (status == 'withdrawn') {
        await loadMyProposals(refresh: true);
      } else {
        await loadReceivedProposals(refresh: true);
        await loadMyCases(refresh: true);
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error actualizando propuesta: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Eliminar caso del marketplace (solo si no está asignado)
  Future<bool> deleteMarketplaceCase({
    required String caseId,
    required String caseTitle,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await SupabaseService.deleteMarketplaceCaseIfNotAssigned(
        caseId: caseId,
        clientId: user.id,
      );
      
      // Actualizar listas locales
      await Future.wait([
        loadMyCases(refresh: true),
        loadReceivedProposals(refresh: true),
      ]);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error eliminando caso: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // ========================================
  // UTILIDADES
  // ========================================
  
  // Verificar si ya envié propuesta a un caso
  bool hasProposalForCase(String caseId) {
    return _myProposals.any((proposal) => proposal['case_id'] == caseId);
  }
  
  // Obtener propuesta para un caso específico
  Map<String, dynamic>? getProposalForCase(String caseId) {
    try {
      return _myProposals.firstWhere((proposal) => proposal['case_id'] == caseId);
    } catch (e) {
      return null;
    }
  }
  
  // Obtener estadísticas del abogado
  Map<String, int> getLawyerStats() {
    final Map<String, int> stats = {
      'total_proposals': _myProposals.length,
      'pending_proposals': 0,
      'accepted_proposals': 0,
      'rejected_proposals': 0,
    };
    
    for (final proposal in _myProposals) {
      final status = proposal['status'] ?? 'pending';
      switch (status) {
        case 'pending':
          stats['pending_proposals'] = stats['pending_proposals']! + 1;
          break;
        case 'accepted':
          stats['accepted_proposals'] = stats['accepted_proposals']! + 1;
          break;
        case 'rejected':
          stats['rejected_proposals'] = stats['rejected_proposals']! + 1;
          break;
      }
    }
    
    return stats;
  }
  
  // Obtener estadísticas del cliente
  Map<String, int> getClientStats() {
    final Map<String, int> stats = {
      'total_cases': _myCases.length,
      'open_cases': 0,
      'assigned_cases': 0,
      'completed_cases': 0,
      'total_proposals': _receivedProposals.length,
    };
    
    for (final case_ in _myCases) {
      final status = case_['status'] ?? 'open';
      switch (status) {
        case 'open':
          stats['open_cases'] = stats['open_cases']! + 1;
          break;
        case 'assigned':
          stats['assigned_cases'] = stats['assigned_cases']! + 1;
          break;
        case 'completed':
          stats['completed_cases'] = stats['completed_cases']! + 1;
          break;
      }
    }
    
    return stats;
  }
  
  // Limpiar datos
  void clearData() {
    _marketplaceCases.clear();
    _myProposals.clear();
    _receivedProposals.clear();
    _myCases.clear();
    notifyListeners();
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
  
  void clearError() {
    _clearError();
  }
  
  // Formatear presupuesto
  String formatBudget(double? budget) {
    if (budget == null) return 'Por negociar';
    return '\$${budget.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} COP';
  }
  
  // Formatear urgencia
  String formatUrgency(String urgency) {
    switch (urgency) {
      case 'low':
        return 'Baja';
      case 'medium':
        return 'Media';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return 'Media';
    }
  }
  
  // Color de urgencia
  Color getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.red.shade900;
      default:
        return Colors.orange;
    }
  }
  
  // Formatear tiempo relativo
  String formatTimeAgo(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }
  
  // ========================================
  // MÉTODOS PARA SISTEMA DE LÍMITES DE PROPUESTAS
  // ========================================
  
  // Obtener número máximo de propuestas por caso (valor por defecto: 5)
  int getMaxProposals(Map<String, dynamic> caseData) {
    return caseData['max_proposals'] ?? 5;
  }
  
  // Obtener contador actual de propuestas
  int getCurrentProposalsCount(Map<String, dynamic> caseData) {
    return caseData['current_proposals_count'] ?? 0;
  }
  
  // Calcular cupos disponibles
  int getAvailableSlots(Map<String, dynamic> caseData) {
    final max = getMaxProposals(caseData);
    final current = getCurrentProposalsCount(caseData);
    return (max - current).clamp(0, max);
  }
  
  // Verificar si un caso acepta más propuestas
  bool canSubmitProposal(Map<String, dynamic> caseData) {
    final status = caseData['status']?.toString() ?? 'open';
    
    // Solo casos con estado 'open' aceptan propuestas
    if (status != 'open') return false;
    
    // Verificar si hay cupos disponibles
    return getAvailableSlots(caseData) > 0;
  }
  
  // Obtener estado visual del caso
  CaseAvailabilityStatus getCaseStatus(Map<String, dynamic> caseData) {
    final status = caseData['status']?.toString() ?? 'open';
    
    // Casos cerrados (propuesta aceptada o asignada)
    if (status == 'accepted' || status == 'assigned') {
      return CaseAvailabilityStatus.closed;
    }
    
    // Casos expirados (más de 7 días sin aceptación)
    if (status == 'expired') {
      return CaseAvailabilityStatus.expired;
    }
    
    // Casos llenos (límite de propuestas alcanzado)
    if (status == 'full') {
      return CaseAvailabilityStatus.full;
    }
    
    final availableSlots = getAvailableSlots(caseData);
    if (availableSlots == 0) {
      return CaseAvailabilityStatus.full;
    }
    
    if (availableSlots <= 2) {
      return CaseAvailabilityStatus.almostFull;
    }
    
    return CaseAvailabilityStatus.open;
  }
  
  // Obtener mensaje descriptivo del estado
  String getStatusMessage(Map<String, dynamic> caseData) {
    final caseStatus = getCaseStatus(caseData);
    final availableSlots = getAvailableSlots(caseData);
    
    switch (caseStatus) {
      case CaseAvailabilityStatus.closed:
        return 'Caso cerrado - Propuesta aceptada';
      case CaseAvailabilityStatus.expired:
        return 'Caso expirado - Sin respuesta del cliente';
      case CaseAvailabilityStatus.full:
        return 'Cupo lleno - No se aceptan más propuestas';
      case CaseAvailabilityStatus.almostFull:
        return '¡Últimos $availableSlots cupo${availableSlots > 1 ? 's' : ''} disponible${availableSlots > 1 ? 's' : ''}!';
      case CaseAvailabilityStatus.open:
        return '$availableSlots cupo${availableSlots > 1 ? 's' : ''} disponible${availableSlots > 1 ? 's' : ''}';
    }
  }
}

// ========================================
// ENUMS
// ========================================

enum CaseAvailabilityStatus {
  open,        // Caso abierto con cupos disponibles
  almostFull,  // Quedan pocos cupos (≤2)
  full,        // Alcanzó el límite de propuestas
  closed,      // Caso cerrado (propuesta aceptada)
  expired,     // Caso expirado (más de 7 días sin aceptación)
}

