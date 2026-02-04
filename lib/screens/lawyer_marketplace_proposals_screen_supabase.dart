import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/marketplace_provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../utils/app_colors.dart';

class LawyerMarketplaceProposalsScreen extends StatefulWidget {
  const LawyerMarketplaceProposalsScreen({super.key});

  @override
  State<LawyerMarketplaceProposalsScreen> createState() => _LawyerMarketplaceProposalsScreenState();
}

class _LawyerMarketplaceProposalsScreenState extends State<LawyerMarketplaceProposalsScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await marketplaceProvider.loadMarketplaceCases(refresh: true, isStudent: authProvider.isStudent);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MarketplaceProvider, AuthProvider>(
      builder: (context, marketplaceProvider, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              authProvider.isStudent ? 'Trámites Jurídicos' : 'Legalmarket',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            actions: [
              TextButton.icon(
                icon: Icon(Icons.filter_list, color: AppColors.onPrimary),
                label: Text(
                  'Filtro',
                  style: GoogleFonts.poppins(
                    color: AppColors.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => _showFilterDialog(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: marketplaceProvider.isLoading
              ? _buildLoadingScreen()
              : _buildAvailableCasesTab(marketplaceProvider),
        );
      },
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
    final client = caseData['user_profiles'] ?? {}; // Obtener datos del cliente desde la relación
    final canSubmit = provider.canSubmitProposal(caseData) && !hasProposal;
    final currentCount = provider.getCurrentProposalsCount(caseData);
    final maxSlots = provider.getMaxProposals(caseData);
    final caseStatus = provider.getCaseStatus(caseData);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusBorderColor(caseStatus),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y badge de estado
            Row(
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
                const SizedBox(width: 8),
                _buildStatusBadge(caseStatus, currentCount, maxSlots),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Categoría y ubicación
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(caseData['category']).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
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
                        size: 16,
                        color: _getCategoryColor(caseData['category']),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        caseData['category'] ?? 'General',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(caseData['category']),
                        ),
                      ),
                    ],
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
                  backgroundImage: client['profile_image_url'] != null
                      ? NetworkImage(client['profile_image_url'])
                      : null,
                  child: client['profile_image_url'] == null
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              'Propuesta Enviada',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: canSubmit ? () => _showSendProposalDialog(caseData, provider) : null,
                        icon: const Icon(Icons.send, size: 16),
                        label: Text(
                          _getButtonLabel(caseStatus),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit ? AppColors.primary : Colors.grey[700],
                          foregroundColor: canSubmit ? Colors.white : Colors.grey[500],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          disabledBackgroundColor: Colors.grey[800],
                          disabledForegroundColor: Colors.grey[600],
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

  Future<void> _showSendProposalDialog(Map<String, dynamic> caseData, MarketplaceProvider provider) async {
    final messageController = TextEditingController();
    final feeController = TextEditingController();
    final daysController = TextEditingController();
    String paymentMethod = 'full'; // Valor por defecto
    
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: messageController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mensaje de propuesta',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    hintText: 'Describe tu experiencia y enfoque...',
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feeController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Honorarios (COP)',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    hintText: '500.000',
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.poppins(color: Colors.white),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: daysController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Días estimados',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    hintText: '30',
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    suffixText: 'días',
                    suffixStyle: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Text(
                  'Método de pago',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  value: 'full',
                  groupValue: paymentMethod,
                  title: 'Único pago de la totalidad de los honorarios al comienzo del proceso',
                  onChanged: (value) => setState(() => paymentMethod = value!),
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  value: 'split',
                  groupValue: paymentMethod,
                  title: 'Dos pagos: uno para empezar y otro para la finalización del proceso',
                  onChanged: (value) => setState(() => paymentMethod = value!),
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  value: 'result',
                  groupValue: paymentMethod,
                  title: 'Pago por resultado (Dependiendo del resultado el abogado cobra un porcentaje de la ganancia económica lograda)',
                  onChanged: (value) => setState(() => paymentMethod = value!),
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  value: 'installments',
                  groupValue: paymentMethod,
                  title: 'Pagos divididos durante el proceso',
                  onChanged: (value) => setState(() => paymentMethod = value!),
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
                    SnackBar(
                      content: Text(
                        'Por favor completa todos los campos',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
              }

              Navigator.pop(context);

              try {
                // Remover puntos del formato de miles antes de parsear
                final feeValue = feeController.text.replaceAll('.', '');
                final success = await provider.sendProposal(
                  caseId: caseData['id'],
                  message: messageController.text,
                  proposedFee: double.parse(feeValue),
                  estimatedDays: int.parse(daysController.text),
                  paymentMethod: paymentMethod,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Propuesta enviada exitosamente'
                            : provider.error ?? 'Error enviando propuesta',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
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
                      content: Text('Error inesperado: $e', style: GoogleFonts.poppins()),
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
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String groupValue,
    required String title,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[600]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.circle,
                      size: 12,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filtrar Casos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 251, 251, 252),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Solo mostrar filtro de categoría si NO es estudiante
            if (!authProvider.isStudent) ...[
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
                    provider.filterCases(category: value, isStudent: authProvider.isStudent);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
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
                  provider.filterCases(location: value, isStudent: authProvider.isStudent);
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
              style: GoogleFonts.poppins(color: const Color.fromARGB(255, 253, 253, 253)),
            ),
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
  
  // Método para construir el badge de estado
  Widget _buildStatusBadge(CaseAvailabilityStatus status, int currentCount, int max) {
    Color badgeColor;
    IconData icon;
    String text;
    
    switch (status) {
      case CaseAvailabilityStatus.open:
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        text = '$currentCount/$max propuestas';
        break;
      case CaseAvailabilityStatus.almostFull:
        badgeColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        text = '$currentCount/$max propuestas';
        break;
      case CaseAvailabilityStatus.full:
        badgeColor = Colors.red;
        icon = Icons.block;
        text = 'Lleno ($currentCount/$max)';
        break;
      case CaseAvailabilityStatus.closed:
        badgeColor = Colors.grey;
        icon = Icons.lock;
        text = 'Cerrado';
        break;
      case CaseAvailabilityStatus.expired:
        badgeColor = Colors.grey[700]!;
        icon = Icons.schedule;
        text = 'Expirado';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusBorderColor(CaseAvailabilityStatus status) {
    switch (status) {
      case CaseAvailabilityStatus.open:
        return Colors.green.withValues(alpha: 0.3);
      case CaseAvailabilityStatus.almostFull:
        return Colors.orange.withValues(alpha: 0.3);
      case CaseAvailabilityStatus.full:
        return Colors.red.withValues(alpha: 0.3);
      case CaseAvailabilityStatus.closed:
        return Colors.grey.withValues(alpha: 0.3);
      case CaseAvailabilityStatus.expired:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }
  
  String _getButtonLabel(CaseAvailabilityStatus status) {
    switch (status) {
      case CaseAvailabilityStatus.full:
        return 'Cupo Lleno';
      case CaseAvailabilityStatus.closed:
        return 'Caso Cerrado';
      case CaseAvailabilityStatus.expired:
        return 'Caso Expirado';
      default:
        return 'Enviar Propuesta';
    }
  }
}

// Formateador personalizado para separadores de miles
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remover cualquier formato existente
    final numericValue = newValue.text.replaceAll('.', '');

    // Formatear con puntos como separadores de miles
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedValue = numericValue.replaceAllMapped(
      formatter,
      (Match match) => '${match[1]}.',
    );

    // Calcular la nueva posición del cursor
    final oldSelectionOffset = oldValue.selection.baseOffset;
    final oldDotsBeforeCursor = '.'.allMatches(oldValue.text.substring(0, oldSelectionOffset)).length;
    final newDotsBeforeCursor = '.'.allMatches(formattedValue.substring(0, numericValue.length.clamp(0, formattedValue.length))).length;
    final cursorOffset = newValue.selection.baseOffset + (newDotsBeforeCursor - oldDotsBeforeCursor);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, formattedValue.length),
      ),
    );
  }
}
