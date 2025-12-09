import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/marketplace_provider.dart';
import '../utils/app_images.dart';
import '../utils/app_colors.dart';

class OffersListScreenSupabase extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const OffersListScreenSupabase({super.key, this.onBackToDashboard});

  @override
  State<OffersListScreenSupabase> createState() => _OffersListScreenSupabaseState();
}

class _OffersListScreenSupabaseState extends State<OffersListScreenSupabase> {
  List<Map<String, dynamic>> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Postpone data loading until after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOffers();
    });
  }

  Future<void> _loadOffers() async {
    try {
      // Obtener propuestas recibidas del MarketplaceProvider
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      await marketplaceProvider.loadReceivedProposals(refresh: true);
      
      if (!mounted) return;
      setState(() {
        offers = marketplaceProvider.receivedProposals;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ofertas: $e')),
        );
      }
    }
  }
  
  Future<void> _updateProposalStatus(String proposalId, String status) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    
    try {
      final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
      final success = await marketplaceProvider.updateProposalStatus(
        proposalId: proposalId,
        status: status,
      );
      
      if (success) {
        // Recargar propuestas después de actualizar
        await _loadOffers();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'accepted' 
                  ? '¡Propuesta aceptada! El abogado ha sido notificado.'
                  : 'Propuesta rechazada'),
              backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        throw Exception('No se pudo actualizar el estado de la propuesta');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar propuesta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDAA520),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              AppImages.logoLogic,
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.gavel, color: Colors.white, size: 30);
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Mis Ofertas',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes ofertas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Las ofertas que recibas aparecerán aquí',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final caseDetails = offer['case_details'] ?? {};
                    final lawyerProfile = offer['lawyer_profile'] ?? {};
                    final proposedFee = offer['proposed_fee'] as double?;
                    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
                    
                    // Información del abogado
                    final lawyerName = lawyerProfile['full_name'] ?? 'Abogado';
                    final lawyerRating = (lawyerProfile['rating'] ?? 0.0).toDouble();
                    final resolvedCases = lawyerProfile['resolved_cases'] ?? 0;
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Franja amarilla con información del abogado
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDAA520),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar del abogado
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 35,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Información del abogado
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lawyerName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            lawyerRating.toStringAsFixed(1),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.check_circle,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$resolvedCases casos resueltos',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white,
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
                          // Contenido de la propuesta
                          ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              caseDetails['title'] ?? 'Propuesta de caso',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Honorarios: ${marketplaceProvider.formatBudget(proposedFee)}',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: const Color(0xFFDAA520),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mensaje del abogado:',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        offer['message'] ?? 'Sin mensaje',
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 20, color: Colors.grey[700]),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tiempo estimado: ${offer['estimated_days'] ?? 0} días',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Icon(Icons.check, color: Colors.white),
                                            label: Text(
                                              'Aceptar',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () => _updateProposalStatus(offer['id'], 'accepted'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Icon(Icons.close, color: Colors.white),
                                            label: Text(
                                              'Rechazar',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () => _updateProposalStatus(offer['id'], 'rejected'),
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
                    );
                  },
                ),
    );
  }
}
