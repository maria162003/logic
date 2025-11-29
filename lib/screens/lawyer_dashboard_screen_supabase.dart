import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider_supabase.dart';
import '../providers/marketplace_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/connection_status_badge.dart';
import 'lawyer_marketplace_proposals_screen_supabase.dart';
import 'lawyer_configuration_screen.dart';
import 'lawyer_case_details_screen.dart';

class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Mover la carga de datos a un post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar datos del marketplace
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      await marketplaceProvider.loadMyProposals();
      
      // Obtener estadísticas
      _stats = marketplaceProvider.getLawyerStats();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(authProvider),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images_logo/imagen_fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: _isLoading 
                ? _buildLoadingScreen()
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(authProvider),
                      _buildTabBar(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildTabContent(),
                      ),
                    ],
                  ),
                ),
            ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false, // Elimina el espacio del botón de retroceso
      title: Row(
        children: [
          // Logo de Logic Lex - igual que el panel de cliente
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'images_logo/Icono-Logic-IA_Blanco-Transparente.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.gavel,
                    size: 28,
                    color: AppColors.onPrimary,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: ConnectionStatusBadge(),
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.onPrimary),
          onPressed: () => _showNotifications(),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.onPrimary),
          onSelected: (value) => _handleMenuAction(value, authProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Text('Mi Perfil'),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Text('Configuración'),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando dashboard...',
            style: GoogleFonts.poppins(color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images_logo/imagen_fondo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        children: [
          // Información del abogado
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                backgroundImage: authProvider.userAvatar != null
                    ? NetworkImage(authProvider.userAvatar!)
                    : null,
                child: authProvider.userAvatar == null
                    ? Text(
                        authProvider.userName?.substring(0, 1).toUpperCase() ?? 'A',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A5F),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido,',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      authProvider.userName ?? 'Abogado',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (authProvider.userLocation != null)
                      Text(
                        authProvider.userLocation!,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Estadísticas rápidas
          _buildStatsCards(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Propuestas',
            _stats['total_proposals']?.toString() ?? '0',
            Icons.send_outlined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pendientes',
            _stats['pending_proposals']?.toString() ?? '0',
            Icons.schedule,
            AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Aceptadas',
            _stats['accepted_proposals']?.toString() ?? '0',
            Icons.check_circle_outline,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rechazadas',
            _stats['rejected_proposals']?.toString() ?? '0',
            Icons.cancel_outlined,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          AppColors.goldShadow,
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    if (_tabController == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController!,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Legalmarket'),
          Tab(text: 'Mis Casos'),
          Tab(text: 'Mensajes'),
          Tab(text: 'Finanzas'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_tabController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return TabBarView(
      controller: _tabController!,
      children: [
        const LawyerMarketplaceProposalsScreen(),
        _buildMyCasesTab(),
        _buildMessagesTab(),
        _buildFinancesTab(),
      ],
    );
  }

  Widget _buildMyCasesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.getLawyerAcceptedCases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar casos',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        final activeCases = snapshot.data ?? [];
        
        if (activeCases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cases_outlined,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mis Casos Activos',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los casos aceptados aparecerán aquí',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeCases.length,
            itemBuilder: (context, index) {
              final case_ = activeCases[index];
              return _buildActiveCaseCard(case_);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildActiveCaseCard(Map<String, dynamic> case_) {
    final DateTime createdAt = DateTime.parse(case_['created_at']);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
    
    // Obtener datos de la propuesta aceptada
    final List<dynamic> proposals = case_['proposals'] ?? [];
    final Map<String, dynamic>? acceptedProposal = proposals.isNotEmpty ? proposals.first : null;
    final double fee = acceptedProposal?['proposed_fee']?.toDouble() ?? case_['budget']?.toDouble() ?? 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACEPTADO',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              case_['title'] ?? 'Sin título',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (case_['category'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  case_['category'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${fee.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'En Progreso',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Solo dejamos el botón de Ver Detalles
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LawyerCaseDetailsScreen(
                        caseData: case_,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Ver Detalles'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getLawyerCasesWithMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar mensajes: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }
        
        final casesWithMessages = snapshot.data ?? [];
        
        if (casesWithMessages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin mensajes',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay conversaciones activas con clientes',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: casesWithMessages.length,
          itemBuilder: (context, index) {
            final caseData = casesWithMessages[index];
            return _buildCaseMessageCard(caseData);
          },
        );
      },
    );
  }

  Widget _buildCaseMessageCard(Map<String, dynamic> caseData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            caseData['title']?.toString().substring(0, 1).toUpperCase() ?? 'C',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          caseData['title'] ?? 'Sin título',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${caseData['client_name'] ?? 'Desconocido'}',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              '${caseData['message_count'] ?? 0} mensajes',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chat,
          color: AppColors.primary,
        ),
        onTap: () => _openCaseChat(caseData),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getLawyerCasesWithMessages() async {
    try {
      // Obtener casos aceptados del abogado (del marketplace)
      final acceptedCases = await SupabaseService.getLawyerAcceptedCases();
      
      List<Map<String, dynamic>> casesWithMessages = [];
      
      for (var caseData in acceptedCases) {
        // Obtener mensajes de cada caso usando el ID del caso
        final messages = await SupabaseService.getChatMessages(caseData['id']);
        
        casesWithMessages.add({
          ...caseData,
          'message_count': messages.length,
          'last_message': messages.isNotEmpty ? messages.last['message'] : 'Sin mensajes',
        });
      }
      
      return casesWithMessages;
    } catch (e) {
      print('Error al obtener casos con mensajes: $e');
      return [];
    }
  }

  void _openCaseChat(Map<String, dynamic> caseData) {
    // Usar el mismo chat screen que usan los clientes pero desde perspectiva del abogado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LawyerChatScreen(caseData: caseData),
      ),
    );
  }

  Widget _buildFinancesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Finanzas',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pagos y ganancias',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Notificaciones',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('No tienes notificaciones nuevas'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, AuthProvider authProvider) {
    switch (action) {
      case 'profile':
        _showProfile();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'logout':
        _showLogoutDialog(authProvider);
        break;
    }
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('Edición de perfil próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LawyerConfigurationScreen(),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

// Pantalla de chat para el abogado con AppBar mejorado
class _LawyerChatScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const _LawyerChatScreen({required this.caseData});

  @override
  State<_LawyerChatScreen> createState() => _LawyerChatScreenState();
}

class _LawyerChatScreenState extends State<_LawyerChatScreen> {
  String? clientName;
  String? clientPhoto;
  String? clientLocation;
  bool _isLoadingClientInfo = true;

  @override
  void initState() {
    super.initState();
    _loadClientInfo();
  }

  Future<void> _loadClientInfo() async {
    final clientId = widget.caseData['client_id'];
    if (clientId == null) {
      setState(() {
        clientName = 'Cliente';
        _isLoadingClientInfo = false;
      });
      return;
    }
    
    try {
      final response = await SupabaseService.client
          .from('user_profiles')
          .select('full_name, profile_image_url, location')
          .eq('id', clientId)
          .single();
      
      if (mounted) {
        setState(() {
          clientName = response['full_name'] ?? 'Cliente';
          clientPhoto = response['profile_image_url'];
          clientLocation = response['location'];
          _isLoadingClientInfo = false;
        });
      }
    } catch (e) {
      print('Error cargando información del cliente: $e');
      if (mounted) {
        setState(() {
          clientName = widget.caseData['client_name'] ?? 'Cliente';
          _isLoadingClientInfo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: _isLoadingClientInfo
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                children: [
                  // Foto de perfil del cliente
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: clientPhoto != null && clientPhoto!.isNotEmpty
                        ? NetworkImage(clientPhoto!)
                        : null,
                    child: clientPhoto == null || clientPhoto!.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Información del cliente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName ?? 'Cliente',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (clientLocation != null && clientLocation!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withOpacity(0.8),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  clientLocation!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      body: _LawyerChatView(
        caseData: widget.caseData,
        clientPhoto: clientPhoto,
      ),
    );
  }
}

// Widget para la vista de chat del abogado
class _LawyerChatView extends StatefulWidget {
  final Map<String, dynamic> caseData;
  final String? clientPhoto;

  const _LawyerChatView({
    required this.caseData,
    this.clientPhoto,
  });

  @override
  State<_LawyerChatView> createState() => _LawyerChatViewState();
}

class _LawyerChatViewState extends State<_LawyerChatView> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final chatMessages = await SupabaseService.getChatMessages(widget.caseData['id']);
      setState(() {
        messages = chatMessages;
        isLoading = false;
      });
      await SupabaseService.markMessagesAsRead(widget.caseData['id']);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar mensajes: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || isSending) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      isSending = true;
    });

    try {
      await SupabaseService.sendChatMessage(
        caseId: widget.caseData['id'],
        message: messageText,
        senderType: 'lawyer',
      );

      await _loadMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje enviado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar mensaje: $e')),
        );
      }
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Lista de mensajes
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay mensajes aún',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia la conversación con tu cliente',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isFromLawyer = message['sender_type'] == 'lawyer';
                    final timestamp = message['created_at'] != null 
                        ? DateTime.parse(message['created_at'])
                        : DateTime.now();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isFromLawyer 
                            ? MainAxisAlignment.end 
                            : MainAxisAlignment.start,
                        children: [
                          if (!isFromLawyer) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              backgroundImage: widget.clientPhoto != null && 
                                      widget.clientPhoto!.isNotEmpty
                                  ? NetworkImage(widget.clientPhoto!)
                                  : null,
                              child: widget.clientPhoto == null || 
                                      widget.clientPhoto!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isFromLawyer 
                                    ? AppColors.primary 
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isFromLawyer ? 16 : 4),
                                  bottomRight: Radius.circular(isFromLawyer ? 4 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['message'] ?? '',
                                    style: GoogleFonts.poppins(
                                      color: isFromLawyer 
                                          ? Colors.white 
                                          : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm').format(timestamp),
                                    style: GoogleFonts.poppins(
                                      color: isFromLawyer 
                                          ? Colors.white.withOpacity(0.8) 
                                          : Colors.grey[700],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isFromLawyer) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.gavel,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        
        // Campo de entrada de mensajes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isSending ? null : _sendMessage,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.send, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
