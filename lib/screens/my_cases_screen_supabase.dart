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
      Provider.of<MarketplaceProvider>(context, listen: false).loadMyCases(refresh: true);
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
                image: AssetImage('images_logo/imagen_fondo.jpg'),
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
      iconTheme: const IconThemeData(color: Colors.black),
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
            onPressed: () => Provider.of<MarketplaceProvider>(context, listen: false).loadMyCases(refresh: true),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Casos',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalCases.toString(), AppColors.primary),
              _buildStatItem('Activos', activeCases.toString(), Colors.green),
              _buildStatItem('Pendientes', pendingCases.toString(), Colors.orange),
              _buildStatItem('Completados', completedCases.toString(), Colors.blue),
            ],
          ),
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
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final canDelete = status == 'open'; // Solo casos abiertos pueden eliminarse
    final isInProgress = status == 'assigned' || status == 'active';
    final lawyerProfile = case_['accepted_proposal']?['lawyer_profile'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.business_center,
                color: Colors.white,
              ),
            ),
            title: Text(
              case_['title'] ?? 'Sin título',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  case_['description'] ?? 'Sin descripción',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Si está en progreso, mostrar información del abogado
                if (isInProgress && lawyerProfile != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAA520).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFDAA520).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFDAA520),
                          backgroundImage: lawyerProfile['profile_image_url'] != null
                              ? NetworkImage(lawyerProfile['profile_image_url'])
                              : null,
                          child: lawyerProfile['profile_image_url'] == null
                              ? const Icon(Icons.person, color: Colors.white, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lawyerProfile['full_name'] ?? 'Abogado',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${lawyerProfile['rating'] ?? 0.0} • ${lawyerProfile['resolved_cases'] ?? 0} casos',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
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
                  const SizedBox(height: 8),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatDate(case_['created_at']),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '\$${_formatBudget(
                                case_['budget'], 
                                status: case_['status'], 
                                acceptedProposal: case_['accepted_proposal']?['proposed_fee']
                              )}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(case_['status']),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(case_['status']),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              _showCaseDetails(case_);
            },
          ),
          
          // Botones de acción para casos abiertos
          if (canDelete) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCaseDetails(case_),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text(
                      'Ver Detalles',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteCase(case_),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: Text(
                      'Eliminar',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          
          // Botón de chat para casos en progreso
          if (isInProgress)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openCaseChat(case_),
                  icon: const Icon(Icons.chat_bubble, size: 18),
                  label: Text(
                    'Abrir Chat con Abogado',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDAA520),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupCasesByLegalArea(List<Map<String, dynamic>> cases) {
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

  List<Map<String, dynamic>> _getFilteredCases(List<Map<String, dynamic>> cases) {
    if (_selectedFilter == 'Todos') {
      return cases;
    }
    
    return cases.where((case_) {
      final category = case_['category']?.toString() ?? case_['legal_area']?.toString() ?? '';
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
      final DateTime parsedDate = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  String _formatBudget(dynamic budget, {String? status, dynamic acceptedProposal}) {
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
      final double amount = budget is double ? budget : double.parse(budget.toString());
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
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            case_['title'] ?? 'Sin título',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Descripción', case_['description'] ?? 'Sin descripción'),
                _buildDetailRow('Área Legal', case_['category'] ?? case_['legal_area'] ?? 'General'),
                _buildDetailRow('Estado', _getStatusText(case_['status'])),
                
                // Información del abogado si está en progreso
                if (isInProgress && lawyerProfile != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAA520).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFDAA520).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abogado Asignado',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color(0xFFDAA520),
                              backgroundImage: lawyerProfile['profile_image_url'] != null
                                  ? NetworkImage(lawyerProfile['profile_image_url'])
                                  : null,
                              child: lawyerProfile['profile_image_url'] == null
                                  ? const Icon(Icons.person, color: Colors.white, size: 25)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lawyerProfile['full_name'] ?? 'Abogado',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${lawyerProfile['rating'] ?? 0.0}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${lawyerProfile['resolved_cases'] ?? 0} casos',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[700],
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
                  ),
                  const SizedBox(height: 16),
                ],
                
                _buildDetailRow('Presupuesto', '\$${_formatBudget(
                  case_['budget'], 
                  status: case_['status'], 
                  acceptedProposal: case_['accepted_proposal']?['proposed_fee']
                )}'),
                _buildDetailRow('Fecha de Creación', _formatDate(case_['created_at'])),
                if (case_['deadline'] != null)
                  _buildDetailRow('Fecha Límite', _formatDate(case_['deadline'])),
              ],
            ),
          ),
          actions: [
            // Mostrar botón de mensajes si el caso está en progreso
            if (isInProgress)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openCaseChat(case_);
                },
                icon: const Icon(Icons.chat_bubble, size: 16),
                label: Text(
                  'Abrir Chat',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
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
  
  // Información del otro usuario
  String? otherUserName;
  String? otherUserPhoto;
  String? otherUserLocation;

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
      // Obtener información del abogado
      await _loadOtherUserInfo(widget.caseData['lawyer_id']);
    } else {
      currentUserType = 'lawyer';
      // Obtener información del cliente
      await _loadOtherUserInfo(widget.caseData['client_id']);
    }

    await _loadMessages();
    await SupabaseService.markMessagesAsRead(widget.caseData['id']);
    _setupRealtimeSubscription();
  }

  Future<void> _loadOtherUserInfo(String? userId) async {
    if (userId == null) return;
    
    try {
      final response = await SupabaseService.client
          .from('user_profiles')
          .select('full_name, profile_image_url, location')
          .eq('id', userId)
          .single();
      
      if (mounted) {
        setState(() {
          otherUserName = response['full_name'] ?? 'Usuario';
          otherUserPhoto = response['profile_image_url'];
          otherUserLocation = response['location'];
        });
      }
    } catch (e) {
      print('Error cargando información del usuario: $e');
      if (mounted) {
        setState(() {
          otherUserName = currentUserType == 'client' ? 'Abogado' : 'Cliente';
        });
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
      title: currentUserType == 'client' ? 'Mensaje del Abogado' : 'Mensaje del Cliente',
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
      final loadedMessages = await SupabaseService.getChatMessages(widget.caseData['id']);
      
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
    if (_messageController.text.trim().isEmpty && _attachedFiles.isEmpty) return;

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
        title: Row(
          children: [
            // Foto de perfil del otro usuario
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: otherUserPhoto != null && otherUserPhoto!.isNotEmpty
                  ? NetworkImage(otherUserPhoto!)
                  : null,
              child: otherUserPhoto == null || otherUserPhoto!.isEmpty
                  ? Icon(
                      currentUserType == 'client' ? Icons.gavel : Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Información del otro usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName ?? (currentUserType == 'client' ? 'Abogado' : 'Cliente'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (otherUserLocation != null && otherUserLocation!.isNotEmpty)
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
                            otherUserLocation!,
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] ?? false;
    final timestamp = message['timestamp'] as DateTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage: otherUserPhoto != null && otherUserPhoto!.isNotEmpty
                  ? NetworkImage(otherUserPhoto!)
                  : null,
              child: otherUserPhoto == null || otherUserPhoto!.isEmpty
                  ? Icon(
                      currentUserType == 'client' ? Icons.gavel : Icons.person,
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
                      color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[700],
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
            _buildInfoRow('Área Legal', widget.caseData['category'] ?? widget.caseData['legal_area'] ?? 'General'),
            _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy').format(
              DateTime.parse(widget.caseData['created_at'].toString())
            )),
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
