import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/marketplace_provider.dart';
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Mis Casos Legales',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: AppColors.onPrimary),
          onPressed: _showFilterDialog,
        ),
      ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando casos...',
            style: GoogleFonts.poppins(
              color: AppColors.onBackground,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar casos',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Provider.of<MarketplaceProvider>(context, listen: false)
                    .loadMyCases(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 100,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes casos registrados',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando crees un caso legal o recibas ofertas de abogados, aparecerán aquí organizados por área legal.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar a crear nuevo caso
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-case');
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Nuevo Caso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<Map<String, dynamic>> cases) {
    final Map<String, int> statusCount = {};
    final Map<String, int> typeCount = {};
    
    for (final case_ in cases) {
      final status = case_['status'] ?? 'Sin estado';
      final type = case_['case_type'] ?? case_['category'] ?? 'Sin categoría';
      
      statusCount[status] = (statusCount[status] ?? 0) + 1;
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          AppColors.goldShadow,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de Casos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  cases.length.toString(),
                  Icons.folder,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Activos',
                  (statusCount['active'] ?? statusCount['abierto'] ?? 0).toString(),
                  Icons.play_circle_filled,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Áreas',
                  typeCount.keys.length.toString(),
                  Icons.category,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = option;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.3),
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.white30,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCasesList(List<Map<String, dynamic>> cases) {
    // Agrupar casos por área legal
    final Map<String, List<Map<String, dynamic>>> groupedCases = {};
    
    for (final case_ in cases) {
      final area = case_['case_type'] ?? case_['category'] ?? 'Sin categoría';
      if (!groupedCases.containsKey(area)) {
        groupedCases[area] = [];
      }
      groupedCases[area]!.add(case_);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedCases.keys.length,
      itemBuilder: (context, index) {
        final area = groupedCases.keys.elementAt(index);
        final areaCases = groupedCases[area]!;
        
        return _buildAreaSection(area, areaCases);
      },
    );
  }

  Widget _buildAreaSection(String area, List<Map<String, dynamic>> cases) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del área
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getAreaIcon(area),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  area,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cases.length.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Casos del área
          ...cases.map((case_) => _buildCaseCard(case_)).toList(),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> case_) {
    final title = case_['title'] ?? 'Sin título';
    final description = case_['description'] ?? 'Sin descripción';
    final status = case_['status'] ?? 'Sin estado';
    final type = case_['case_type'] ?? case_['category'] ?? 'Sin categoría';
    final createdAt = case_['created_at'];
    final isInProgress = status.toLowerCase() == 'assigned' || status.toLowerCase() == 'active';
    
    DateTime? date;
    if (createdAt != null) {
      try {
        date = DateTime.parse(createdAt.toString());
      } catch (e) {
        // Si no se puede parsear, date quedará null
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
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
              // Header con título
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Descripción
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Info adicional
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date != null 
                        ? DateFormat('dd/MM/yyyy').format(date)
                        : 'Fecha no disponible',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _getAreaIcon(type),
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              // Mostrar progreso y estado si está en progreso
              if (isInProgress) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColorForStatus(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColorForStatus(status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Indicador de progreso
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: (case_['progress'] ?? 0) / 100,
                              strokeWidth: 3,
                              backgroundColor: Colors.grey[700],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(case_['progress'] ?? 0),
                              ),
                            ),
                            Text(
                              '${case_['progress'] ?? 0}%',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getProgressColor(case_['progress'] ?? 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Estado del caso
                      _buildStatusChip(status),
                    ],
                  ),
                ),
              ],
              // Si no está en progreso, mostrar solo el estado
              if (!isInProgress) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(status),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'active':
      case 'abierto':
      case 'activo':
        statusColor = AppColors.success;
        statusText = 'Activo';
        break;
      case 'closed':
      case 'cerrado':
        statusColor = AppColors.error;
        statusText = 'Cerrado';
        break;
      case 'pending':
      case 'pendiente':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case 'in_progress':
      case 'en_progreso':
        statusColor = Colors.blue;
        statusText = 'En Progreso';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.isNotEmpty ? status : 'Sin estado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  IconData _getAreaIcon(String area) {
    switch (area.toLowerCase()) {
      case 'civil':
        return Icons.account_balance;
      case 'penal':
        return Icons.gavel;
      case 'laboral':
        return Icons.work;
      case 'familiar':
        return Icons.family_restroom;
      case 'comercial':
        return Icons.business;
      case 'administrativo':
        return Icons.admin_panel_settings;
      case 'constitucional':
        return Icons.description;
      case 'tributario':
        return Icons.receipt;
      case 'ambiental':
        return Icons.eco;
      case 'tecnológico':
        return Icons.computer;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getProgressColor(int progress) {
    if (progress < 25) {
      return Colors.red;
    } else if (progress < 50) {
      return Colors.orange;
    } else if (progress < 75) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  Color _getStatusColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'abierto':
      case 'activo':
        return AppColors.success;
      case 'assigned':
        return Colors.green;
      case 'closed':
      case 'cerrado':
        return AppColors.error;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      case 'in_progress':
      case 'en_progreso':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getFilteredCases(List<Map<String, dynamic>> cases) {
    if (_selectedFilter == 'Todos') {
      return cases;
    }
    
    return cases.where((case_) {
      final type = case_['case_type'] ?? case_['category'] ?? '';
      return type.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Filtrar por Área Legal',
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              final option = _filterOptions[index];
              return ListTile(
                leading: Icon(
                  _getAreaIcon(option),
                  color: AppColors.primary,
                ),
                title: Text(
                  option,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                trailing: _selectedFilter == option
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedFilter = option;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
