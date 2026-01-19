import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/marketplace_provider.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class MyCasesScreenSupabase extends StatefulWidget {
  const MyCasesScreenSupabase({super.key});

  @override
  State<MyCasesScreenSupabase> createState() => _MyCasesScreenSupabaseState();
}

class _MyCasesScreenSupabaseState extends State<MyCasesScreenSupabase> {
  String _selectedFilter = 'Todos';
  final Set<String> _expandedOffers =
      {}; // Para controlar qué casos tienen ofertas desplegadas
  final List<String> _filterOptions = [
    'Todos',
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(context, listen: false)
          .loadMyCases(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/imagen_fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () => provider.loadMyCases(refresh: true),
              color: AppColors.primary,
              child: _buildBody(provider),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        'Mis Casos Legales',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }

  Widget _buildBody(MarketplaceProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingScreen();
    }

    if (provider.error != null) {
      return _buildErrorScreen(provider.error!);
    }

    final filteredCases = _getFilteredCases(provider.myCases);

    // Si hay casos totales pero ninguno para el filtro actual
    if (filteredCases.isEmpty &&
        provider.myCases.isNotEmpty &&
        _selectedFilter != 'Todos') {
      return Column(
        children: [
          _buildStatsCard(provider.myCases),
          _buildFilterChips(),
          Expanded(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: _buildEmptyFilterState(),
            ),
          ),
        ],
      );
    }

    if (filteredCases.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildStatsCard(filteredCases),
        _buildFilterChips(),
        Expanded(
          child: _buildCasesList(filteredCases),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar casos',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                Provider.of<MarketplaceProvider>(context, listen: false)
                    .loadMyCases(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes casos',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus casos aparecerán aquí cuando los publiques',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getLegalAreaIcon(_selectedFilter),
              size: 50,
              color: AppColors.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay casos para $_selectedFilter',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'No tienes casos en esta categoría',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'Todos';
                });
              },
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Ver todos'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<Map<String, dynamic>> cases) {
    final totalCases = cases.length;

    // Activos: assigned, active
    final activeCases = cases.where((c) {
      final status = c['status']?.toLowerCase();
      return status == 'assigned' || status == 'active';
    }).length;

    // Pendientes: open, pending
    final pendingCases = cases.where((c) {
      final status = c['status']?.toLowerCase();
      return status == 'open' || status == 'pending';
    }).length;

    // Completados: completed, cancelled
    final completedCases = cases.where((c) {
      final status = c['status']?.toLowerCase();
      return status == 'completed' || status == 'cancelled';
    }).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalCases.toString(), AppColors.primary),
          _buildStatItem('Activos', activeCases.toString(), Colors.green),
          _buildStatItem('Pendientes', pendingCases.toString(), Colors.orange),
          _buildStatItem('Completados', completedCases.toString(), Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtrar por área legal:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        if (isSelected) const SizedBox(width: 4),
                        Text(filter),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: const Color(0xFFDAA520),
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: isSelected ? 4 : 0,
                    shadowColor: const Color(0xFFDAA520).withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList(List<Map<String, dynamic>> cases) {
    final groupedCases = _groupCasesByLegalArea(cases);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedCases.keys.length,
      itemBuilder: (context, index) {
        final legalArea = groupedCases.keys.elementAt(index);
        final areaCases = groupedCases[legalArea]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegalAreaHeader(legalArea, areaCases.length),
            ...areaCases.map((case_) => _buildCaseCard(case_)).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildLegalAreaHeader(String legalArea, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getLegalAreaIcon(legalArea),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            legalArea,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> case_) {
    final status = case_['status']?.toString().toLowerCase();
    final canDelete = status == 'open';
    final isOpen = status == 'open';
    final isInProgress = status == 'assigned' || status == 'active';
    final lawyerProfile = case_['accepted_proposal']?['lawyer_profile'];
    final legalArea =
        case_['legal_area'] ?? case_['category'] ?? 'Sin categoría';
    final areaColor = _getLegalAreaColor(legalArea);
    final caseId = case_['id']?.toString() ?? '';
    final proposals = case_['proposals'] as List? ?? [];
    final isExpanded = _expandedOffers.contains(caseId);

    // Calcular días transcurridos desde asignación
    int daysElapsed = 0;
    if (isInProgress && case_['updated_at'] != null) {
      try {
        final updatedDate = DateTime.parse(case_['updated_at'].toString());
        daysElapsed = DateTime.now().difference(updatedDate).inDays;
      } catch (e) {
        daysElapsed = 0;
      }
    }

    // Calcular progreso del caso (simulado por ahora, puede ser basado en estado)
    double progress = 0.0;
    if (status == 'assigned') progress = 0.25;
    if (status == 'active') progress = 0.50;
    if (status == 'completed') progress = 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Icono área legal + Título + Círculo de progreso
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del área legal con color
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: areaColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getLegalAreaIcon(legalArea),
                    color: areaColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Título y descripción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        case_['title'] ?? 'Sin título',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        case_['description'] ?? 'Sin descripción',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Estado y círculo de progreso
                Column(
                  children: [
                    // Badge de estado arriba del círculo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(case_['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(case_['status']),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Círculo de progreso con diseño moderno
                    if (isInProgress)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor:
                                    const Color(0xFF5D4037), // Marrón oscuro
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF9800)), // Naranja
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'PROGRESS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información de fechas y presupuesto
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(case_['created_at']),
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '\$${_formatBudget(case_['budget'], status: case_['status'], acceptedProposal: case_['accepted_proposal']?['proposed_fee'])}',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[400]),
                ),
                if (isInProgress && daysElapsed > 0) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: areaColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$daysElapsed día${daysElapsed != 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: areaColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Información del abogado asignado (solo en ver detalles)
            if (false && isInProgress && lawyerProfile != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: areaColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: areaColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: areaColor,
                      backgroundImage:
                          (lawyerProfile['profile_image_url'] != null)
                              ? NetworkImage(lawyerProfile['profile_image_url'])
                              : null,
                      child: (lawyerProfile['profile_image_url'] == null)
                          ? const Icon(Icons.gavel,
                              color: Colors.white, size: 22)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lawyerProfile['full_name'] ?? 'Abogado Asignado',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (lawyerProfile['location'] != null)
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    lawyerProfile['location'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                    ),
                                    maxLines: 1,
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
            ],

            // Botones de acción en fila
            const SizedBox(height: 12),

            // Para casos ABIERTOS: Ver ofertas + Flecha + Eliminar
            if (isOpen) ...[
              Row(
                children: [
                  // Botón Ver ofertas con badge
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_expandedOffers.contains(caseId)) {
                            _expandedOffers.remove(caseId);
                          } else {
                            _expandedOffers.add(caseId);
                          }
                        });
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.local_offer,
                              size: 18, color: AppColors.primary),
                          if (proposals.isNotEmpty)
                            Positioned(
                              right: -8,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${proposals.length}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: Text('Ver ofertas',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.primary)),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ),
                  // Flecha toggle para desplegar ofertas
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_expandedOffers.contains(caseId)) {
                          _expandedOffers.remove(caseId);
                        } else {
                          _expandedOffers.add(caseId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  // Botón Eliminar
                  TextButton.icon(
                    onPressed: () => _confirmDeleteCase(case_),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: Text('Eliminar',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.red)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ],
              ),
              // Lista de ofertas desplegable
              if (isExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: proposals.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No hay ofertas aún',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[400], fontSize: 13),
                            ),
                          ),
                        )
                      : Column(
                          children: proposals
                              .map<Widget>((proposal) =>
                                  _buildProposalCard(proposal, case_))
                              .toList(),
                        ),
                ),
              ],
            ],

            // Para casos EN PROGRESO: Ver Detalles + Chat
            if (isInProgress) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCaseDetails(case_),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: Text('Ver Detalles',
                          style: GoogleFonts.poppins(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openCaseChat(case_),
                      icon: const Icon(Icons.chat_bubble,
                          size: 16, color: Colors.white),
                      label: Text(
                        'Abrir Chat con Abogado',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Para otros estados (completed, etc): Solo Ver Detalles
            if (!isOpen && !isInProgress) ...[
              OutlinedButton.icon(
                onPressed: () => _showCaseDetails(case_),
                icon: const Icon(Icons.visibility, size: 16),
                label: Text('Ver Detalles',
                    style: GoogleFonts.poppins(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget para mostrar cada oferta/propuesta de abogado
  Widget _buildProposalCard(
      Map<String, dynamic> proposal, Map<String, dynamic> case_) {
    final lawyerProfile = proposal['lawyer_profile'] ?? {};
    final lawyerName = lawyerProfile['full_name'] ?? 'Abogado';
    final lawyerLocation = lawyerProfile['location'] ?? 'Sin ubicación';
    final lawyerType = lawyerProfile['is_student'] == true
        ? 'Estudiante derecho'
        : 'Abogado profesional';
    final specializations = lawyerProfile['specializations'] as List? ?? [];
    final specializationText = specializations.isNotEmpty 
        ? specializations.take(3).join(', ')
        : 'Derecho general';
    final rating = lawyerProfile['rating']?.toString() ?? '4.0';
    final profileImage = lawyerProfile['profile_image_url'];
    final message =
        proposal['message'] ?? proposal['cover_letter'] ?? 'Sin mensaje';
    final proposedFee = proposal['proposed_fee'];
    final estimatedDays = proposal['estimated_days'] ?? 30;
    final proposalId = proposal['id']?.toString() ?? '';
    final isProposalExpanded = _expandedOffers.contains('proposal_$proposalId');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Rating + Info + Foto
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating con estrella
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 3),
                    Text(rating,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Nombre, ubicación y tipo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lawyerName.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('$lawyerLocation / $lawyerType',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
              // Foto del abogado a la derecha
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null
                    ? const Icon(Icons.person, color: Colors.white, size: 22)
                    : null,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Propuesta de caso
          Text('Propuesta de caso',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text('Mensaje del abogado:',
              style:
                  GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[300], height: 1.4),
            maxLines: isProposalExpanded ? 20 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Contenido expandido
          if (isProposalExpanded) ...[
            const SizedBox(height: 16),
            
            // Tiempo estimado
            Row(
              children: [
                Text('Tiempo estimado:',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[400])),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$estimatedDays días',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Honorarios
            Row(
              children: [
                Text('Honorarios:',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[400])),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[600]!, width: 1),
                  ),
                  child: Text(
                      proposedFee != null 
                          ? '\$ ${_formatCurrency(proposedFee)} COP'
                          : 'Por definir',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones Aceptar y Declinar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptProposal(proposal, case_),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Aceptar',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rejectProposal(proposal, case_),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Declinar',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Flecha para colapsar
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedOffers.remove('proposal_$proposalId');
                  });
                },
                child: const Icon(Icons.keyboard_arrow_up,
                    color: Colors.grey, size: 28),
              ),
            ),
          ],
          
          // Flecha para expandir (cuando está colapsado)
          if (!isProposalExpanded) ...[
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedOffers.add('proposal_$proposalId');
                  });
                },
                child: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey, size: 28),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final number = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Future<void> _acceptProposal(
      Map<String, dynamic> proposal, Map<String, dynamic> case_) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Aceptar Propuesta',
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text('¿Estás seguro de que deseas aceptar esta propuesta?',
            style: GoogleFonts.poppins(color: Colors.grey[300])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Aceptar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.updateProposalStatus(
          proposalId: proposal['id'].toString(),
          status: 'accepted',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Propuesta aceptada exitosamente'),
                backgroundColor: Colors.green),
          );
          Provider.of<MarketplaceProvider>(context, listen: false)
              .loadMyCases(refresh: true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al aceptar: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _rejectProposal(
      Map<String, dynamic> proposal, Map<String, dynamic> case_) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Rechazar Propuesta',
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text('¿Estás seguro de que deseas rechazar esta propuesta?',
            style: GoogleFonts.poppins(color: Colors.grey[300])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Rechazar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.updateProposalStatus(
          proposalId: proposal['id'].toString(),
          status: 'rejected',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Propuesta rechazada'),
                backgroundColor: Colors.orange),
          );
          Provider.of<MarketplaceProvider>(context, listen: false)
              .loadMyCases(refresh: true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al rechazar: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupCasesByLegalArea(
      List<Map<String, dynamic>> cases) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final case_ in cases) {
      final legalArea = case_['legal_area'] ?? 'Sin categoría';
      if (!grouped.containsKey(legalArea)) {
        grouped[legalArea] = [];
      }
      grouped[legalArea]!.add(case_);
    }

    return grouped;
  }

  IconData _getLegalAreaIcon(String legalArea) {
    switch (legalArea.toLowerCase()) {
      case 'civil':
        return Icons.account_balance;
      case 'penal':
        return Icons.security;
      case 'laboral':
        return Icons.work;
      case 'familiar':
        return Icons.family_restroom;
      case 'comercial':
        return Icons.business;
      case 'administrativo':
        return Icons.admin_panel_settings;
      case 'constitucional':
        return Icons.gavel;
      case 'tributario':
        return Icons.receipt;
      case 'ambiental':
        return Icons.eco;
      case 'tecnológico':
        return Icons.computer;
      default:
        return Icons.folder;
    }
  }

  Color _getLegalAreaColor(String legalArea) {
    switch (legalArea.toLowerCase()) {
      case 'civil':
        return Colors.blueGrey;
      case 'penal':
        return Colors.red;
      case 'laboral':
        return Colors.green;
      case 'familiar':
        return Colors.purple;
      case 'comercial':
        return Colors.orange;
      case 'administrativo':
        return Colors.indigo;
      case 'constitucional':
        return Colors.teal;
      case 'tributario':
        return Colors.brown;
      case 'ambiental':
        return Colors.lightGreen;
      case 'tecnológico':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  List<Map<String, dynamic>> _getFilteredCases(
      List<Map<String, dynamic>> cases) {
    if (_selectedFilter == 'Todos') {
      return cases;
    }

    return cases.where((case_) {
      final category = case_['category']?.toString() ??
          case_['legal_area']?.toString() ??
          '';
      return category == _selectedFilter;
    }).toList();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'assigned':
        return Colors.green;
      case 'active':
        return Colors.purple;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return 'Abierto';
      case 'assigned':
        return 'Asignado';
      case 'active':
        return 'En Progreso';
      case 'pending':
        return 'Pendiente';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Sin Estado';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Sin fecha';

    try {
      final DateTime parsedDate =
          date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  String _formatBudget(dynamic budget,
      {String? status, dynamic acceptedProposal}) {
    // Si el caso está asignado y tenemos una propuesta aceptada, mostrar el precio acordado
    if (status?.toLowerCase() == 'assigned' && acceptedProposal != null) {
      try {
        final double amount = acceptedProposal is double
            ? acceptedProposal
            : double.parse(acceptedProposal.toString());
        final formatter = NumberFormat('#,##0', 'es_CO');
        return '${formatter.format(amount)} COP (Acordado)';
      } catch (e) {
        // Si falla, usar el presupuesto original
      }
    }

    // Mostrar presupuesto original
    if (budget == null) return 'Por negociar';

    try {
      final double amount =
          budget is double ? budget : double.parse(budget.toString());
      final formatter = NumberFormat('#,##0', 'es_CO');
      return '${formatter.format(amount)} COP';
    } catch (e) {
      return 'Por negociar';
    }
  }

  void _showCaseDetails(Map<String, dynamic> case_) {
    final status = case_['status']?.toString().toLowerCase();
    final isInProgress = status == 'assigned' || status == 'active';
    final lawyerProfile = case_['accepted_proposal']?['lawyer_profile'];
    final legalArea =
        case_['legal_area'] ?? case_['category'] ?? 'Sin categoría';
    final areaColor = _getLegalAreaColor(legalArea);

    int daysElapsed = 0;
    if (case_['created_at'] != null) {
      try {
        final createdDate = DateTime.parse(case_['created_at'].toString());
        daysElapsed = DateTime.now().difference(createdDate).inDays;
      } catch (e) {
        daysElapsed = 0;
      }
    }

    double progress = 0.0;
    int progressPercent = 0;
    if (status == 'open') {
      progress = 0.1;
      progressPercent = 10;
    }
    if (status == 'assigned') {
      progress = 0.25;
      progressPercent = 25;
    }
    if (status == 'active') {
      progress = 0.50;
      progressPercent = 50;
    }
    if (status == 'completed') {
      progress = 1.0;
      progressPercent = 100;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: areaColor.withOpacity(0.3), width: 1),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  case_['title'] ?? 'Sin título',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Descripción
                Text('Descripción',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.grey[500])),
                Text(
                  case_['description'] ?? 'Sin descripción',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey[300]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Fila principal: Info + Timeline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info izquierda
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Área Legal',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: Colors.grey[500])),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: areaColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getLegalAreaIcon(legalArea),
                                    color: areaColor, size: 14),
                                const SizedBox(width: 4),
                                Text(legalArea,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: areaColor)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Tiempo transcurrido',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: Colors.grey[500])),
                          Text('$daysElapsed días',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Presupuesto',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: Colors.grey[500])),
                          Text(
                              '\$${_formatBudget(case_['budget'], status: case_['status'], acceptedProposal: case_['accepted_proposal']?['proposed_fee'])}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Fecha de Creación',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: Colors.grey[500])),
                          Text(_formatDate(case_['created_at']),
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Timeline derecha
                    Expanded(
                      child: Column(
                        children: [
                          _buildTimelineItem(
                              'En preparación',
                              status == 'open' ||
                                  status == 'assigned' ||
                                  status == 'active' ||
                                  status == 'completed',
                              _formatDate(case_['created_at']),
                              AppColors.primary),
                          _buildTimelineItem(
                              'En trámite',
                              status == 'active' || status == 'completed',
                              status == 'active' ? 'Más de 30 días' : '',
                              AppColors.primary),
                          _buildTimelineItem(
                              'Completado',
                              status == 'completed',
                              status == 'completed'
                                  ? _formatDate(case_['updated_at'])
                                  : '',
                              AppColors.primary,
                              isLast: true),
                          const SizedBox(height: 10),
                          // Círculo de progreso
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 4,
                                    backgroundColor: const Color(0xFF5D4037),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFF9800)),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('PROGRESS',
                                        style: GoogleFonts.poppins(
                                            fontSize: 5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600])),
                                    Text('$progressPercent%',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Información del Abogado
                if (isInProgress && lawyerProfile != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: areaColor,
                          backgroundImage: lawyerProfile['profile_image_url'] !=
                                  null
                              ? NetworkImage(lawyerProfile['profile_image_url'])
                              : null,
                          child: lawyerProfile['profile_image_url'] == null
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 11),
                              const SizedBox(width: 2),
                              Text('${lawyerProfile['rating'] ?? 4.1}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  lawyerProfile['full_name']
                                          ?.toString()
                                          .toUpperCase() ??
                                      'ABOGADO',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(
                                  '${lawyerProfile['location'] ?? 'Colombia'} / Abogado',
                                  style: GoogleFonts.poppins(
                                      fontSize: 9, color: Colors.grey[400]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Botones
                Row(
                  children: [
                    if (isInProgress) ...[
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openCaseChat(case_);
                          },
                          icon: const Icon(Icons.arrow_forward,
                              size: 14, color: AppColors.primary),
                          label: Text('Abrir Chat',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8)),
                        ),
                      ),
                    ],
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: Text('Cerrar',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400])),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(
      String title, bool isActive, String subtitle, Color color,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.grey[700],
                border: Border.all(
                  color: isActive ? color : Colors.grey[600]!,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isActive ? color.withOpacity(0.5) : Colors.grey[700],
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              SizedBox(height: isLast ? 0 : 15),
            ],
          ),
        ),
      ],
    );
  }

  // Confirmar eliminación de caso con doble verificación
  void _confirmDeleteCase(Map<String, dynamic> case_) {
    final titleController = TextEditingController();
    final caseTitle = case_['title'] ?? 'Sin título';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Eliminar Caso',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Esta acción es PERMANENTE y NO se puede deshacer.',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Para confirmar la eliminación, escribe exactamente el título del caso:',
                    style: GoogleFonts.poppins(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      caseTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Escribe el título exacto aquí...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Actualizar UI cuando cambie el texto
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleController.dispose();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: titleController.text.trim() == caseTitle.trim()
                      ? () {
                          titleController.dispose();
                          Navigator.of(context).pop();
                          _deleteCase(case_);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Eliminar Permanentemente',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Eliminar caso después de la confirmación
  void _deleteCase(Map<String, dynamic> case_) async {
    try {
      final provider = Provider.of<MarketplaceProvider>(context, listen: false);

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(
                'Eliminando caso...',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      );

      final success = await provider.deleteMarketplaceCase(
        caseId: case_['id'],
        caseTitle: case_['title'] ?? '',
      );

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Caso eliminado exitosamente',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.error ?? 'Error al eliminar el caso',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga si existe
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error inesperado: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openCaseChat(Map<String, dynamic> case_) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CaseChatScreen(caseData: case_),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Pantalla de chat funcional
class _CaseChatScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const _CaseChatScreen({required this.caseData});

  @override
  State<_CaseChatScreen> createState() => _CaseChatScreenState();
}

class _CaseChatScreenState extends State<_CaseChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;
  late String currentUserId;
  late String currentUserType; // 'client' o 'lawyer'
  List<PlatformFile> _attachedFiles = [];
  bool _isUploadingFiles = false;
  RealtimeChannel? _messagesChannel;
  Map<String, dynamic>?
      _otherUserProfile; // Perfil del otro usuario (abogado o cliente)
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Determinar si el usuario actual es cliente o abogado
    final user = SupabaseService.currentUser;
    if (user == null) return;

    currentUserId = user.id;

    // Verificar si es el cliente del caso
    if (widget.caseData['client_id'] == currentUserId) {
      currentUserType = 'client';
    } else {
      currentUserType = 'lawyer';
    }

    await _loadMessages();
    await _loadOtherUserProfile();
    await SupabaseService.markMessagesAsRead(widget.caseData['id']);
    _setupRealtimeSubscription();
  }

  Future<void> _loadOtherUserProfile() async {
    try {
      setState(() => _isLoadingProfile = true);

      // Obtener el ID del otro usuario (abogado si soy cliente, o cliente si soy abogado)
      String otherUserId = '';

      if (currentUserType == 'client') {
        // Soy cliente, obtener info del abogado
        // Intentar múltiples fuentes de lawyer_id

        // 1. Desde assigned_lawyer_id
        otherUserId = widget.caseData['assigned_lawyer_id'] ?? '';
        print('DEBUG: assigned_lawyer_id: $otherUserId');

        // 2. Desde accepted_proposal
        if (otherUserId.isEmpty &&
            widget.caseData['accepted_proposal'] != null) {
          otherUserId = widget.caseData['accepted_proposal']['lawyer_id'] ?? '';
          print('DEBUG: lawyer_id desde accepted_proposal: $otherUserId');
        }

        // 3. Desde proposals (buscar propuesta aceptada)
        if (otherUserId.isEmpty && widget.caseData['proposals'] != null) {
          final proposals = widget.caseData['proposals'] as List;
          for (var proposal in proposals) {
            if (proposal['status'] == 'accepted') {
              otherUserId = proposal['lawyer_id'] ?? '';
              print('DEBUG: lawyer_id desde proposals aceptadas: $otherUserId');
              break;
            }
          }
        }

        // 4. Desde primer mensaje del chat (si hay conversación activa)
        if (otherUserId.isEmpty && messages.isNotEmpty) {
          final currentUserId = SupabaseService.currentUser?.id;
          for (var msg in messages) {
            if (msg['sender_id'] != currentUserId) {
              // Este mensaje es del abogado, intentar obtener su perfil
              final senderId = msg['sender_id'];
              try {
                final profile =
                    await SupabaseService.getLawyerProfile(senderId);
                if (profile != null) {
                  otherUserId = senderId;
                  print('DEBUG: lawyer_id desde mensajes: $otherUserId');
                  break;
                }
              } catch (e) {
                // No es un abogado, continuar
              }
            }
          }
        }

        print(
            '🔍 DEBUG: ID del abogado a buscar: ${otherUserId.isEmpty ? "NO ENCONTRADO" : otherUserId}');

        if (otherUserId.isNotEmpty) {
          _otherUserProfile =
              await SupabaseService.getLawyerProfile(otherUserId);
          print(
              '✅ DEBUG: Perfil de abogado cargado: ${_otherUserProfile?['full_name'] ?? "sin nombre"}');
        } else {
          print('⚠️ DEBUG: No se pudo encontrar ID de abogado asignado');
        }
      } else {
        // Soy abogado, obtener info del cliente
        otherUserId = widget.caseData['client_id'] ?? '';
        print('DEBUG: Buscando cliente con ID: $otherUserId');

        if (otherUserId.isNotEmpty) {
          _otherUserProfile = await SupabaseService.getUserProfile(otherUserId);
          print(
              'DEBUG: Perfil de cliente obtenido: ${_otherUserProfile != null ? "✅" : "❌"}');
        }
      }

      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      print('❌ Error cargando perfil del otro usuario: $e');
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  void _setupRealtimeSubscription() {
    final caseId = widget.caseData['id'];

    _messagesChannel = SupabaseService.client
        .channel('chat_messages:$caseId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'case_id',
            value: caseId,
          ),
          callback: (payload) {
            _handleNewMessage(payload);
          },
        )
        .subscribe();
  }

  void _handleNewMessage(PostgresChangePayload payload) {
    final newMessage = payload.newRecord;

    // No notificar si el mensaje es del usuario actual
    if (newMessage['sender_id'] == currentUserId) {
      return;
    }

    // Mostrar notificación
    NotificationService.showMessageNotification(
      title: currentUserType == 'client'
          ? 'Mensaje del Abogado'
          : 'Mensaje del Cliente',
      body: newMessage['message'],
      payload: 'case:${widget.caseData['id']}',
    );

    // Actualizar la lista de mensajes
    if (mounted) {
      setState(() {
        messages.add({
          'id': newMessage['id'],
          'sender': newMessage['sender_type'],
          'message': newMessage['message'],
          'timestamp': DateTime.parse(newMessage['created_at']),
          'isMe': false,
        });
      });

      _scrollToBottom();
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final loadedMessages =
          await SupabaseService.getChatMessages(widget.caseData['id']);

      setState(() {
        messages = loadedMessages.map((msg) {
          return {
            'id': msg['id'],
            'sender': msg['sender_type'],
            'message': msg['message'],
            'timestamp': DateTime.parse(msg['created_at']),
            'isMe': msg['sender_id'] == currentUserId,
          };
        }).toList();
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error cargando mensajes: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _attachedFiles.isEmpty)
      return;

    final userMessage = _messageController.text.trim();
    final filesToSend = List<PlatformFile>.from(_attachedFiles);

    _messageController.clear();
    setState(() {
      _attachedFiles.clear();
      _isUploadingFiles = filesToSend.isNotEmpty;
    });

    try {
      // Construir mensaje con información de archivos si hay adjuntos
      String finalMessage = userMessage;
      if (filesToSend.isNotEmpty) {
        finalMessage += '\n\n📎 Archivos adjuntos (${filesToSend.length}):';
        for (var file in filesToSend) {
          finalMessage += '\n• ${file.name} (${_formatFileSize(file.size)})';
        }
      }

      // Enviar mensaje a la base de datos
      final success = await SupabaseService.sendChatMessage(
        caseId: widget.caseData['id'],
        message: finalMessage,
        senderType: currentUserType,
      );

      if (mounted) {
        setState(() {
          _isUploadingFiles = false;
        });
      }

      if (success) {
        // Recargar mensajes para mostrar el nuevo mensaje
        await _loadMessages();

        // Mostrar mensaje informativo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                filesToSend.isNotEmpty
                    ? 'Mensaje y archivos enviados correctamente'
                    : 'Mensaje enviado. El abogado responderá pronto.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Error al enviar mensaje');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingFiles = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al enviar mensaje. Intenta de nuevo.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesChannel?.unsubscribe();
    super.dispose();
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
        title: _buildChatHeader(),
        actions: [
          IconButton(
            onPressed: () {
              // Mostrar información del caso
              _showCaseInfo();
            },
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(messages[index]);
                        },
                      ),
          ),
          // Input de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'Inicia la conversación',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía un mensaje para comenzar\nel chat con tu abogado',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    if (_isLoadingProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chat del Caso',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Cargando perfil...',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    // Extraer información del perfil
    String userName;
    String userLocation = '';
    String? avatarUrl;

    if (_otherUserProfile != null) {
      print('DEBUG: Perfil cargado: $_otherUserProfile');

      if (currentUserType == 'client') {
        // Mostrando info del abogado
        userName = _otherUserProfile!['user_profiles']?['full_name'] ??
            _otherUserProfile!['full_name'] ??
            'Abogado';
        userLocation = _otherUserProfile!['user_profiles']?['location'] ??
            _otherUserProfile!['location'] ??
            '';
        avatarUrl = _otherUserProfile!['user_profiles']?['avatar_url'] ??
            _otherUserProfile!['avatar_url'];
      } else {
        // Mostrando info del cliente
        userName = _otherUserProfile!['full_name'] ?? 'Cliente';
        userLocation = _otherUserProfile!['location'] ?? '';
        avatarUrl = _otherUserProfile!['avatar_url'];
      }
    } else {
      // No hay perfil cargado
      print('DEBUG: No se pudo cargar el perfil del otro usuario');
      print('DEBUG: currentUserType: $currentUserType');
      print('DEBUG: Case data: ${widget.caseData}');

      userName =
          currentUserType == 'client' ? 'Abogado (No asignado)' : 'Cliente';
    }

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Icon(
                  currentUserType == 'client' ? Icons.gavel : Icons.person,
                  color: AppColors.primary,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(width: 12),
        // Información del usuario
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (userLocation.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userLocation,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] ?? false;
    final timestamp = message['timestamp'] as DateTime;

    // Obtener avatar del otro usuario
    String? avatarUrl;
    if (!isMe && _otherUserProfile != null) {
      if (currentUserType == 'client') {
        avatarUrl = _otherUserProfile!['user_profiles']?['avatar_url'] ??
            _otherUserProfile!['avatar_url'];
      } else {
        avatarUrl = _otherUserProfile!['avatar_url'];
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
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
                color: isMe ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: GoogleFonts.poppins(
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[700],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.primary, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lista de archivos adjuntos
            if (_attachedFiles.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _attachedFiles[index];
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getFileIcon(file.extension ?? ''),
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  file.name.length > 10
                                      ? '${file.name.substring(0, 10)}...'
                                      : file.name,
                                  style: GoogleFonts.poppins(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            // Barra de entrada
            Row(
              children: [
                // Botón de adjuntar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: _pickFiles,
                    icon: Icon(Icons.attach_file, color: AppColors.primary),
                    tooltip: 'Adjuntar archivos',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isUploadingFiles ? Colors.grey : AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: _isUploadingFiles ? null : _sendMessage,
                    icon: _isUploadingFiles
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showCaseInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Información del Caso',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Título', widget.caseData['title'] ?? 'Sin título'),
            _buildInfoRow('Estado', _getStatusText(widget.caseData['status'])),
            _buildInfoRow(
                'Área Legal',
                widget.caseData['category'] ??
                    widget.caseData['legal_area'] ??
                    'General'),
            _buildInfoRow(
                'Fecha',
                DateFormat('dd/MM/yyyy').format(
                    DateTime.parse(widget.caseData['created_at'].toString()))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return 'Abierto';
      case 'assigned':
        return 'Asignado';
      case 'active':
        return 'En Progreso';
      case 'pending':
        return 'Pendiente';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Sin Estado';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
