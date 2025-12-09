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

// Función para formatear moneda en formato colombiano
String _formatCurrency(double amount) {
  final formatter = NumberFormat('#,##0', 'es_CO');
  return formatter.format(amount);
}

class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _proposalFilter =
      'all'; // Filtro de propuestas: all, accepted, pending, rejected
  String _caseFilter =
      'all'; // Filtro de casos: all, assigned, active, completed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Cargar datos del marketplace
      final marketplaceProvider =
          Provider.of<MarketplaceProvider>(context, listen: false);
      await marketplaceProvider.loadMyProposals();

      // Obtener estadísticas
      _stats = marketplaceProvider.getLawyerStats();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
      automaticallyImplyLeading:
          false, // Elimina el espacio del botón de retroceso
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
                        authProvider.userName?.substring(0, 1).toUpperCase() ??
                            'A',
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
          Tab(text: 'Mis Propuestas'),
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
        _buildMyProposalsTab(),
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

        final allCases = snapshot.data ?? [];

        // Filtrar casos según el filtro seleccionado
        final activeCases = _caseFilter == 'all'
            ? allCases
            : allCases
                .where((case_) => case_['status'] == _caseFilter)
                .toList();

        // Calcular contadores para los filtros
        final allCount = allCases.length;
        final assignedCount =
            allCases.where((c) => c['status'] == 'assigned').length;
        final activeCount =
            allCases.where((c) => c['status'] == 'active').length;
        final completedCount =
            allCases.where((c) => c['status'] == 'completed').length;

        return Column(
          children: [
            // Filtros
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildCaseFilterChip('all', 'Todos', allCount, Icons.list),
                  const SizedBox(width: 8),
                  _buildCaseFilterChip('assigned', 'En Preparación',
                      assignedCount, Icons.assignment),
                  const SizedBox(width: 8),
                  _buildCaseFilterChip('active', 'En Trámite', activeCount,
                      Icons.pending_actions),
                  const SizedBox(width: 8),
                  _buildCaseFilterChip('completed', 'Completado',
                      completedCount, Icons.check_circle),
                ],
              ),
            ),

            // Lista de casos
            Expanded(
              child: activeCases.isEmpty
                  ? Center(
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
                            'No hay casos',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCaseEmptyMessage(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
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
                    ),
            ),
          ],
        );
      },
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 25) {
      return Colors.red; // Rojo para 0-24%
    } else if (progress < 50) {
      return Colors.orange; // Naranja para 25-49%
    } else if (progress < 75) {
      return Colors.blue; // Azul para 50-74%
    } else {
      return Colors.green; // Verde para 75-100%
    }
  }

  Widget _buildActiveCaseCard(Map<String, dynamic> case_) {
    final DateTime createdAt = DateTime.parse(case_['created_at']);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);

    // Obtener datos de la propuesta aceptada
    final List<dynamic> proposals = case_['proposals'] ?? [];
    final Map<String, dynamic>? acceptedProposal =
        proposals.isNotEmpty ? proposals.first : null;
    final double fee = acceptedProposal?['proposed_fee']?.toDouble() ??
        case_['budget']?.toDouble() ??
        0.0;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'EN PREPARACIÓN',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Spacer(),
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
            const SizedBox(height: 8),
            // Información del cliente
            if (case_['user_profiles'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    case_['user_profiles']['full_name'] ?? 'Cliente',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      case_['user_profiles']['location'] ?? 'Sin ubicación',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
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
                  '${_formatCurrency(fee)} COP',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                // Indicador de progreso circular con botón para actualizar
                GestureDetector(
                  onTap: () => _showUpdateProgressDialog(case_),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: (case_['progress'] ?? 0) / 100,
                          strokeWidth: 4,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(case_['progress'] ?? 0),
                          ),
                        ),
                        Text(
                          '${case_['progress'] ?? 0}%',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(case_['progress'] ?? 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Botones de Ver Detalles y Chat
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LawyerCaseDetailsScreen(
                            caseData: case_,
                          ),
                        ),
                      );
                      // Refrescar la vista cuando regresamos
                      setState(() {});
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
                const SizedBox(width: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: SupabaseService.getChatMessages(case_['id']),
                  builder: (context, messageSnapshot) {
                    final messageCount = messageSnapshot.hasData
                        ? messageSnapshot.data!.length
                        : 0;
                    return ElevatedButton(
                      onPressed: () => _openCaseChat(case_),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAA520),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.chat_bubble, size: 20),
                          if (messageCount > 0)
                            Positioned(
                              right: -8,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  messageCount > 9
                                      ? '9+'
                                      : messageCount.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
    // Obtener el nombre del cliente desde user_profiles
    final userProfiles = caseData['user_profiles'];
    final clientName =
        userProfiles is Map ? userProfiles['full_name'] : 'Desconocido';
    final clientPhoto =
        userProfiles is Map ? userProfiles['profile_image_url'] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage:
              clientPhoto != null ? NetworkImage(clientPhoto) : null,
          child: clientPhoto == null
              ? Text(
                  (clientName ?? 'C').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
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
              'Cliente: ${clientName ?? 'Desconocido'}',
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
          'last_message':
              messages.isNotEmpty ? messages.last['message'] : 'Sin mensajes',
        });
      }

      return casesWithMessages;
    } catch (e) {
      print('Error al obtener casos con mensajes: $e');
      return [];
    }
  }

  Widget _buildMyProposalsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.getLawyerProposals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final allProposals = snapshot.data ?? [];

        // Filtrar propuestas según el filtro seleccionado
        final filteredProposals = _proposalFilter == 'all'
            ? allProposals
            : allProposals
                .where((p) => p['status'] == _proposalFilter)
                .toList();

        return Column(
          children: [
            // Filtros
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child:
                        _buildFilterChip('Todos', 'all', allProposals.length),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'Aceptadas',
                      'accepted',
                      allProposals
                          .where((p) => p['status'] == 'accepted')
                          .length,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'Pendientes',
                      'pending',
                      allProposals
                          .where((p) => p['status'] == 'pending')
                          .length,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      'Rechazadas',
                      'rejected',
                      allProposals
                          .where((p) => p['status'] == 'rejected')
                          .length,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de propuestas filtradas
            Expanded(
              child: filteredProposals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 80,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _proposalFilter == 'all'
                                ? 'Sin Propuestas'
                                : 'No hay propuestas ${_getFilterLabel(_proposalFilter)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tus propuestas enviadas aparecerán aquí',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProposals.length,
                        itemBuilder: (context, index) {
                          final proposal = filteredProposals[index];
                          return _buildProposalCard(proposal);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String filterValue, int count) {
    final isSelected = _proposalFilter == filterValue;

    Color chipColor;
    IconData chipIcon;

    switch (filterValue) {
      case 'accepted':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'rejected':
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
      case 'pending':
        chipColor = Colors.orange;
        chipIcon = Icons.schedule;
        break;
      default:
        chipColor = AppColors.primary;
        chipIcon = Icons.list;
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _proposalFilter = filterValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? chipColor : Colors.grey[700]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                chipIcon,
                color: isSelected ? chipColor : Colors.grey[500],
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? chipColor : Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? chipColor : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'accepted':
        return 'aceptadas';
      case 'rejected':
        return 'rechazadas';
      case 'pending':
        return 'pendientes';
      default:
        return '';
    }
  }

  Widget _buildCaseFilterChip(
      String filterValue, String label, int count, IconData icon) {
    final isSelected = _caseFilter == filterValue;
    Color chipColor;

    switch (filterValue) {
      case 'assigned':
        chipColor = Colors.green;
        break;
      case 'active':
        chipColor = Colors.blue;
        break;
      case 'completed':
        chipColor = Colors.purple;
        break;
      default:
        chipColor = AppColors.primary;
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _caseFilter = filterValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? chipColor : Colors.grey[700]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? chipColor : Colors.grey[500],
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? chipColor : Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? chipColor : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCaseEmptyMessage() {
    switch (_caseFilter) {
      case 'assigned':
        return 'No hay casos en preparación';
      case 'active':
        return 'No hay casos en trámite';
      case 'completed':
        return 'No hay casos completados';
      default:
        return 'Los casos aceptados aparecerán aquí';
    }
  }

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    final status = proposal['status'] ?? 'pending';
    final caseData = proposal['marketplace_cases'];

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Aceptada';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rechazada';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.schedule;
    }

    return GestureDetector(
      onTap: () => _showCaseDetailsDialog(caseData, proposal),
      child: Card(
        color: const Color(0xFF1A1A1A),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del caso y badge de estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      caseData['title'] ?? 'Sin título',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Categoría con icono y color
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(caseData['category'])
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getCategoryColor(caseData['category']),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(caseData['category']),
                      size: 14,
                      color: _getCategoryColor(caseData['category']),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      caseData['category'] ?? 'General',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _getCategoryColor(caseData['category']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Información del cliente
              if (caseData['user_profiles'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caseData['user_profiles']['full_name'] ??
                                  'Cliente',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (caseData['user_profiles']['location'] !=
                                null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.white60,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    caseData['user_profiles']['location'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Mi Propuesta
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Propuesta:',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proposal['message'] ?? 'Sin mensaje',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Honorarios y Tiempo Estimado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Honorarios Propuestos',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatCurrency(proposal['proposed_fee']?.toDouble() ?? 0.0)} COP',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiempo Estimado',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${proposal['estimated_days'] ?? 0} días',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Fecha de envío
              Text(
                'Enviado hace ${_getTimeAgo(proposal['created_at'])}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCaseDetailsDialog(
      Map<String, dynamic> caseData, Map<String, dynamic> proposal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Información del Caso',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDialogRow('Descripción:',
                            caseData['description'] ?? 'Sin descripción'),
                        const SizedBox(height: 16),
                        _buildDialogRow('Tarifa Acordada:',
                            '\$${_formatCurrency(caseData['budget']?.toDouble() ?? 0.0)}'),
                        const SizedBox(height: 16),
                        _buildDialogRow('Tiempo Estimado:',
                            '${caseData['estimated_days'] ?? 0} días'),
                        const SizedBox(height: 16),
                        _buildDialogRow(
                            'Fecha de Creación:',
                            DateFormat('dd/MM/yyyy HH:mm').format(
                                DateTime.parse(caseData['created_at']))),
                        const SizedBox(height: 16),
                        _buildDialogRow(
                            'Estado:',
                            _getStatusTextForDialog(
                                caseData['status'] ?? 'pending')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _getStatusTextForDialog(String status) {
    switch (status) {
      case 'assigned':
        return 'En preparación';
      case 'active':
        return 'En trámite';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return 'hace tiempo';

    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'unos momentos';
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

  Future<void> _showUpdateProgressDialog(Map<String, dynamic> caseData) async {
    final currentProgress = caseData['progress'] ?? 0;
    int selectedProgress = currentProgress;

    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'Actualizar Progreso',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selecciona el progreso del caso:',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: selectedProgress / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(selectedProgress),
                          ),
                        ),
                        Text(
                          '$selectedProgress%',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(selectedProgress),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: selectedProgress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: _getProgressColor(selectedProgress),
                    label: '$selectedProgress%',
                    onChanged: (value) {
                      setState(() {
                        selectedProgress = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(color: Colors.white60),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedProgress),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Actualizar',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != currentProgress) {
      await _updateCaseProgress(caseData['id'], result);
    }
  }

  Future<void> _updateCaseProgress(String caseId, int progress) async {
    try {
      await SupabaseService.client
          .from('marketplace_cases')
          .update({'progress': progress}).eq('id', caseId);

      if (mounted) {
        setState(() {}); // Refrescar la vista
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Progreso actualizado a $progress%',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar progreso: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      case 'settings':
        _showSettings();
        break;
      case 'logout':
        _showLogoutDialog(authProvider);
        break;
    }
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

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'penal':
        return Icons.gavel;
      case 'laboral':
        return Icons.work;
      case 'comercial':
        return Icons.business;
      case 'administrativo':
        return Icons.account_balance;
      case 'constitucional':
        return Icons.balance;
      case 'familiar':
      case 'familia':
        return Icons.family_restroom;
      case 'civil':
        return Icons.description;
      case 'tributario':
        return Icons.receipt_long;
      default:
        return Icons.folder;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'penal':
        return Colors.red;
      case 'laboral':
        return Colors.green;
      case 'comercial':
        return Colors.blue;
      case 'administrativo':
        return Colors.purple;
      case 'constitucional':
        return Colors.teal;
      case 'familiar':
      case 'familia':
        return Colors.pink;
      case 'civil':
        return Colors.orange;
      case 'tributario':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
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
    // Intentar obtener los datos del cliente desde user_profiles (que viene del JOIN)
    final userProfiles = widget.caseData['user_profiles'];

    if (userProfiles is Map && userProfiles.isNotEmpty) {
      // Los datos ya están disponibles desde el JOIN
      setState(() {
        clientName = userProfiles['full_name'] ?? 'Cliente';
        clientPhoto = userProfiles['profile_image_url'];
        clientLocation = userProfiles['location'];
        _isLoadingClientInfo = false;
      });
      return;
    }

    // Si no están disponibles, intentar obtenerlos desde client_id
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
          clientName = 'Cliente';
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
                    backgroundImage:
                        clientPhoto != null && clientPhoto!.isNotEmpty
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
                        if (clientLocation != null &&
                            clientLocation!.isNotEmpty)
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
      final chatMessages =
          await SupabaseService.getChatMessages(widget.caseData['id']);
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
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isFromLawyer
                                    ? AppColors.primary
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft:
                                      Radius.circular(isFromLawyer ? 16 : 4),
                                  bottomRight:
                                      Radius.circular(isFromLawyer ? 4 : 16),
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
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
