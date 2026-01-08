import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/marketplace_provider.dart';
import '../utils/app_colors.dart';

class LawyerMarketplaceProposalsScreen extends StatefulWidget {
  const LawyerMarketplaceProposalsScreen({super.key});

  @override
  State<LawyerMarketplaceProposalsScreen> createState() => _LawyerMarketplaceProposalsScreenState();
}

class _LawyerMarketplaceProposalsScreenState extends State<LawyerMarketplaceProposalsScreen> 
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    
    if (_tabController?.index == 0) {
      await marketplaceProvider.loadMarketplaceCases(refresh: true);
    } else {
      await marketplaceProvider.loadMyProposals(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Legalmarket',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<MarketplaceProvider>(
            builder: (context, provider, child) {
              if (_tabController?.index == 0) {
                return IconButton(
                  icon: Icon(Icons.filter_list, color: AppColors.onPrimary),
                  onPressed: () => _showFilterDialog(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, marketplaceProvider, child) {
          if (marketplaceProvider.isLoading) {
            return _buildLoadingScreen();
          }

          if (_tabController == null) {
            return _buildLoadingScreen();
          }

          return Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController!,
                  children: [
                    _buildAvailableCasesTab(marketplaceProvider),
                    _buildMyProposalsTab(marketplaceProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
            style: GoogleFonts.poppins(color: AppColors.onBackground),
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
        tabs: const [
          Tab(text: 'Casos Disponibles'),
          Tab(text: 'Mis Propuestas'),
        ],
        onTap: (index) {
          _loadData();
        },
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvailableCasesTab(MarketplaceProvider provider) {
    if (provider.marketplaceCases.isEmpty) {
      return _buildEmptyState(
        icon: Icons.gavel,
        title: 'No hay casos disponibles',
        subtitle: 'Los nuevos casos aparecerán aquí cuando estén disponibles.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.marketplaceCases.length,
        itemBuilder: (context, index) {
          final caseData = provider.marketplaceCases[index];
          return _buildCaseCard(caseData, provider);
        },
      ),
    );
  }

  Widget _buildMyProposalsTab(MarketplaceProvider provider) {
    if (provider.myProposals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send,
        title: 'No has enviado propuestas',
        subtitle: 'Tus propuestas enviadas aparecerán aquí.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.myProposals.length,
        itemBuilder: (context, index) {
          final proposalData = provider.myProposals[index];
          return _buildProposalCard(proposalData, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseData, MarketplaceProvider provider) {
    final hasProposal = provider.hasProposalForCase(caseData['id']);
    final client = {}; // Temporalmente sin datos del cliente
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título
            Text(
              caseData['title'] ?? 'Sin título',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Categoría y ubicación
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    caseData['category'] ?? 'General',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (caseData['location'] != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    caseData['location'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Descripción
            Text(
              caseData['description'] ?? 'Sin descripción',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.primary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Información del cliente
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1E3A5F),
                  backgroundImage: client['avatar_url'] != null
                      ? NetworkImage(client['avatar_url'])
                      : null,
                  child: client['avatar_url'] == null
                      ? Text(
                          client['full_name']?.toString().substring(0, 1).toUpperCase() ?? 'C',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client['full_name'] ?? 'Cliente',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (client['location'] != null)
                        Text(
                          client['location'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Footer con presupuesto y botón
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presupuesto',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      provider.formatBudget(caseData['budget']?.toDouble()),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                hasProposal
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          'Propuesta Enviada',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _showSendProposalDialog(caseData, provider),
                        icon: const Icon(Icons.send, size: 16),
                        label: Text(
                          'Enviar Propuesta',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
              ],
            ),
            
            if (caseData['created_at'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Publicado ${provider.formatTimeAgo(caseData['created_at'])}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProposalCard(Map<String, dynamic> proposalData, MarketplaceProvider provider) {
    // La nueva estructura incluye marketplace_cases como un objeto anidado
    final caseData = proposalData['marketplace_cases'] is List 
        ? (proposalData['marketplace_cases'] as List).isNotEmpty 
            ? proposalData['marketplace_cases'][0] 
            : {}
        : proposalData['marketplace_cases'] ?? {};
    
    final status = proposalData['status'] ?? 'pending';
    
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
      case 'withdrawn':
        statusColor = Colors.grey;
        statusText = 'Retirada';
        statusIcon = Icons.remove_circle;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.schedule;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título del caso y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    caseData['title'] ?? 'Sin título',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 249, 249, 249),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
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
            
            // Categoría del caso
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                caseData['category'] ?? 'General',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Mi propuesta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 77, 76, 76),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color.fromARGB(255, 19, 19, 19)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Propuesta:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 249, 247, 247),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    proposalData['message'] ?? 'Sin mensaje',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 247, 245, 245),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Detalles de la propuesta
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Honorarios Propuestos',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        provider.formatBudget(proposalData['proposed_fee']?.toDouble()),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 246, 246, 247),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo Estimado',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${proposalData['estimated_days'] ?? 0} días',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 251, 251, 252),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Footer con fecha y acción si es necesario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (proposalData['created_at'] != null)
                  Text(
                    'Enviado ${provider.formatTimeAgo(proposalData['created_at'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                if (status == 'pending')
                  TextButton(
                    onPressed: () => _showWithdrawConfirmation(proposalData['id'], provider),
                    child: Text(
                      'Retirar',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSendProposalDialog(Map<String, dynamic> caseData, MarketplaceProvider provider) async {
    final messageController = TextEditingController();
    final feeController = TextEditingController();
    final daysController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enviar Propuesta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Mensaje de propuesta',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
                  hintText: 'Describe tu experiencia y enfoque...',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feeController,
                decoration: InputDecoration(
                  labelText: 'Honorarios (COP)',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
                  hintText: '500000',
                  border: const OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: daysController,
                decoration: InputDecoration(
                  labelText: 'Días estimados',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
                  hintText: '30',
                  border: const OutlineInputBorder(),
                  suffixText: 'días',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.isEmpty ||
                  feeController.text.isEmpty ||
                  daysController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final success = await provider.sendProposal(
                  caseId: caseData['id'],
                  message: messageController.text,
                  proposedFee: double.parse(feeController.text),
                  estimatedDays: int.parse(daysController.text),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Propuesta enviada exitosamente'
                            : provider.error ?? 'Error enviando propuesta',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      action: success ? SnackBarAction(
                        label: 'Ver mis propuestas',
                        textColor: Colors.white,
                        onPressed: () {
                          if (_tabController != null) {
                            _tabController!.animateTo(1);
                          }
                        },
                      ) : null,
                    ),
                  );
                }

                // Recargar los datos si fue exitoso
                if (success) {
                  await _loadData();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error inesperado: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Enviar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWithdrawConfirmation(String proposalId, MarketplaceProvider provider) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Retirar Propuesta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres retirar esta propuesta?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await provider.updateProposalStatus(
                proposalId: proposalId,
                status: 'withdrawn',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Propuesta retirada'
                          : provider.error ?? 'Error retirando propuesta',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Retirar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filtrar Casos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: provider.selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: MarketplaceProvider.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.filterCases(category: value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: provider.selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
              items: MarketplaceProvider.locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.filterCases(location: value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Aplicar',
              style: GoogleFonts.poppins(color: const Color(0xFF1E3A5F)),
            ),
          ),
        ],
      ),
    );
  }
}
