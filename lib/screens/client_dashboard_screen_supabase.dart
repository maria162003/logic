import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider_supabase.dart';
import '../providers/marketplace_provider.dart';
import '../services/supabase_service.dart';
import 'home_screen_supabase.dart';
import 'offers_list_screen_supabase.dart';
import 'my_cases_screen_supabase.dart';
import 'profile_config_screen.dart';
import 'package:intl/intl.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  int _unreadNotificationsCount = 0;
  int _unreadMessagesCount = 0;
  RealtimeChannel? _notificationsChannel;
  RealtimeChannel? _messagesChannel;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreenSupabase(), // Pantalla de Inicio con áreas legales y navegación
      const OffersListScreenSupabase(), // Ver Ofertas Recibidas - NUEVA MEJORADA
      const MyCasesScreenSupabase(), // Mis Casos
      const ProfileConfigScreen(), // Configuración Profesional
    ];
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupRealtimeListeners();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _notificationsChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Actualizar contador cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _updateNotificationCounts();
      }
    });
  }

  Future<void> _loadInitialData() async {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    
    // Cargar casos del cliente y propuestas recibidas
    await Future.wait([
      marketplaceProvider.loadMyCases(),
      marketplaceProvider.loadReceivedProposals(),
    ]);
    
    // Cargar contador de notificaciones
    _updateNotificationCounts();
  }

  Future<void> _updateNotificationCounts() async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) return;

      // Contar propuestas no leídas (ofertas)
      final proposals = await SupabaseService.getClientProposals();
      final unreadProposals = proposals.where((p) => p['status'] == 'pending').length;

      // Contar mensajes no leídos
      final cases = await SupabaseService.getClientCases();
      int unreadMessages = 0;
      
      for (var caseData in cases) {
        final messages = await SupabaseService.getChatMessages(caseData['id']);
        final unread = messages.where((msg) => 
          msg['sender_id'] != currentUser.id && 
          msg['read'] == false
        ).length;
        unreadMessages += unread;
      }

      if (mounted) {
        setState(() {
          _unreadNotificationsCount = unreadProposals;
          _unreadMessagesCount = unreadMessages;
        });
      }
    } catch (e) {
      print('Error al actualizar contador de notificaciones: $e');
    }
  }

  void _setupRealtimeListeners() {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) return;

    // Escuchar nuevas propuestas
    _notificationsChannel = Supabase.instance.client
        .channel('client_proposals_${currentUser.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'proposals',
          callback: (payload) {
            _updateNotificationCounts();
            _showNotificationSnackbar('Nueva oferta recibida', Icons.mail);
          },
        )
        .subscribe();

    // Escuchar nuevos mensajes
    _messagesChannel = Supabase.instance.client
        .channel('client_messages_${currentUser.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            final senderId = payload.newRecord['sender_id'];
            if (senderId != currentUser.id) {
              _updateNotificationCounts();
              _showNotificationSnackbar('Nuevo mensaje recibido', Icons.chat_bubble);
            }
          },
        )
        .subscribe();
  }

  void _showNotificationSnackbar(String message, IconData icon) {
    if (!mounted) return;
    
    // Vibrar (si está disponible en la plataforma)
    // HapticFeedback.mediumImpact(); // Descomentar si quieres vibración
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFBB8B30),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () {
            if (icon == Icons.mail) {
              setState(() => _currentIndex = 1); // Ir a Ofertas
            } else {
              setState(() => _currentIndex = 2); // Ir a Casos
            }
          },
        ),
      ),
    );
  }

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationsPanel(
        onNotificationTap: (type) {
          Navigator.pop(context);
          if (type == 'offer') {
            setState(() => _currentIndex = 1);
          } else if (type == 'message') {
            setState(() => _currentIndex = 2);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(authProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final totalNotifications = _unreadNotificationsCount + _unreadMessagesCount;
    
    return AppBar(
      backgroundColor: const Color(0xFF1A1B23),
      elevation: 0,
      title: Text(
        'Logic - Panel del Cliente',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFBB8B30),
        ),
      ),
      actions: [
        // Botón de notificaciones con badge animado
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFFBB8B30),
                  size: 28,
                ),
                onPressed: _showNotificationsPanel,
                tooltip: 'Ver notificaciones',
              ),
              if (totalNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A1B23), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      totalNotifications > 99 ? '99+' : totalNotifications.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(AuthProvider authProvider) {
    return Consumer<MarketplaceProvider>(
      builder: (context, marketplaceProvider, child) {
        // Contar propuestas no leídas
        final unreadProposals = marketplaceProvider.receivedProposals
            .where((proposal) => proposal['status'] == 'pending')
            .length;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFBB8B30), // Dorado del tema
          unselectedItemColor: Colors.grey,
          backgroundColor: const Color(0xFF1A1B23), // Fondo oscuro
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.mail),
                  if (unreadProposals > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadProposals.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Ofertas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Casos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Config',
            ),
          ],
        );
      },
    );
  }
}

// Widget del Panel de Notificaciones
class _NotificationsPanel extends StatefulWidget {
  final Function(String type) onNotificationTap;

  const _NotificationsPanel({required this.onNotificationTap});

  @override
  State<_NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<_NotificationsPanel> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _proposals = [];
  List<Map<String, dynamic>> _unreadMessages = [];
  List<Map<String, dynamic>> _caseUpdates = [];
  String _selectedTab = 'all'; // 'all', 'offers', 'messages', 'updates'
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) return;

      // Cargar propuestas pendientes
      final proposals = await SupabaseService.getClientProposals();
      
      // Cargar casos del cliente
      final cases = await SupabaseService.getClientCases();
      List<Map<String, dynamic>> unreadMessages = [];
      List<Map<String, dynamic>> caseUpdates = [];
      
      // Procesar cada caso
      for (var caseData in cases) {
        // Obtener mensajes no leídos
        final messages = await SupabaseService.getChatMessages(caseData['id']);
        final unread = messages.where((msg) => 
          msg['sender_id'] != currentUser.id && 
          msg['read'] == false
        );
        
        for (var msg in unread) {
          unreadMessages.add({
            ...msg,
            'case_title': caseData['title'],
            'case_id': caseData['id'],
          });
        }

        // Detectar actualizaciones recientes en casos (últimas 48 horas)
        final updatedAt = DateTime.parse(caseData['updated_at']);
        final now = DateTime.now();
        final hoursSinceUpdate = now.difference(updatedAt).inHours;
        
        if (hoursSinceUpdate < 48 && caseData['status'] != 'active') {
          caseUpdates.add({
            'type': 'case_update',
            'case_id': caseData['id'],
            'case_title': caseData['title'],
            'status': caseData['status'],
            'progress': caseData['progress'],
            'updated_at': caseData['updated_at'],
            'description': _getCaseUpdateDescription(caseData),
          });
        }
      }

      if (mounted) {
        setState(() {
          _proposals = proposals.where((p) => p['status'] == 'pending').toList();
          _unreadMessages = unreadMessages;
          _caseUpdates = caseUpdates;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar notificaciones: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCaseUpdateDescription(Map<String, dynamic> caseData) {
    final status = caseData['status'];
    switch (status) {
      case 'assigned':
        return 'Tu caso ha sido asignado a un abogado';
      case 'in_progress':
        return 'Tu caso está en progreso';
      case 'completed':
        return 'Tu caso ha sido completado';
      case 'cancelled':
        return 'Tu caso ha sido cancelado';
      default:
        return 'Tu caso ha sido actualizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1B23),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFBB8B30)))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xFFBB8B30),
                  child: _buildNotificationsList(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalNotifications = _proposals.length + _unreadMessages.length + _caseUpdates.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252630),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFBB8B30).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Color(0xFFBB8B30),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$totalNotifications sin leer',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          if (totalNotifications > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 16, color: Color(0xFFBB8B30)),
              label: Text(
                'Leer todo',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFFBB8B30),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    // Marcar todos los mensajes como leídos
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) return;

      // Aquí podrías agregar lógica para marcar propuestas como vistas
      // Por ahora solo recargamos
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Todas las notificaciones marcadas como leídas',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        setState(() {
          _proposals.clear();
          _unreadMessages.clear();
          _caseUpdates.clear();
        });
      }
    } catch (e) {
      print('Error al marcar como leídas: $e');
    }
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton('all', 'Todas', _proposals.length + _unreadMessages.length + _caseUpdates.length),
          _buildTabButton('offers', 'Ofertas', _proposals.length),
          _buildTabButton('messages', 'Mensajes', _unreadMessages.length),
          _buildTabButton('updates', 'Casos', _caseUpdates.length),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, int count) {
    final isSelected = _selectedTab == tabId;
    
    return Flexible(
      child: GestureDetector(
        onTap: () {
          if (mounted) {
            setState(() => _selectedTab = tabId);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBB8B30) : const Color(0xFF252630),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFBB8B30) : Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
              if (count > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    List<Widget> notifications = [];

    if (_selectedTab == 'all' || _selectedTab == 'offers') {
      notifications.addAll(_proposals.map((proposal) => _buildOfferNotification(proposal)));
    }

    if (_selectedTab == 'all' || _selectedTab == 'messages') {
      notifications.addAll(_unreadMessages.map((msg) => _buildMessageNotification(msg)));
    }

    if (_selectedTab == 'all' || _selectedTab == 'updates') {
      notifications.addAll(_caseUpdates.map((update) => _buildCaseUpdateNotification(update)));
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes notificaciones',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 200 + (index * 50)),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(1.0),
              curve: Curves.easeOut,
            ),
          ),
          child: notifications[index],
        ),
      ),
    );
  }

  Widget _buildOfferNotification(Map<String, dynamic> proposal) {
    final createdAt = DateTime.parse(proposal['created_at']);
    final timeAgo = _formatTimeAgo(createdAt);
    final lawyerName = proposal['lawyer_profile']?['full_name'] ?? 'Abogado';
    final amount = proposal['amount'] ?? 0;

    return InkWell(
      onTap: () => widget.onNotificationTap('offer'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252630),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBB8B30).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBB8B30).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFBB8B30).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.mail,
                color: Color(0xFFBB8B30),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nueva Oferta',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NUEVA',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lawyerName te envió una propuesta de \$${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageNotification(Map<String, dynamic> message) {
    final createdAt = DateTime.parse(message['created_at']);
    final timeAgo = _formatTimeAgo(createdAt);
    final caseTitle = message['case_title'] ?? 'Caso';
    final messageText = message['message'] ?? '';

    return InkWell(
      onTap: () => widget.onNotificationTap('message'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252630),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nuevo Mensaje',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NUEVO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.folder, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        caseTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    messageText.length > 60 ? '${messageText.substring(0, 60)}...' : messageText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseUpdateNotification(Map<String, dynamic> update) {
    final updatedAt = DateTime.parse(update['updated_at']);
    final timeAgo = _formatTimeAgo(updatedAt);
    final caseTitle = update['case_title'] ?? 'Caso';
    final description = update['description'] ?? 'Tu caso ha sido actualizado';
    final status = update['status'];
    
    // Definir color e ícono según el estado
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'assigned':
        statusColor = Colors.green;
        statusIcon = Icons.person_add;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusIcon = Icons.work;
        break;
      case 'completed':
        statusColor = Colors.purple;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return InkWell(
      onTap: () => widget.onNotificationTap('message'), // Ir a Mis Casos
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252630),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Actualización de Caso',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.folder, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          caseTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Justo ahora';
    }
  }
}
