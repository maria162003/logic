import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

// Función para formatear moneda en formato colombiano
String _formatCurrency(double amount) {
  final formatter = NumberFormat('#,##0', 'es_CO');
  return formatter.format(amount);
}

class LawyerCaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const LawyerCaseDetailsScreen({
    super.key,
    required this.caseData,
  });

  @override
  State<LawyerCaseDetailsScreen> createState() => _LawyerCaseDetailsScreenState();
}

class _LawyerCaseDetailsScreenState extends State<LawyerCaseDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _clientProfile;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadCaseDetails();
  }

  Future<void> _loadCaseDetails() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar perfil del cliente
      final clientData = await SupabaseService.getUserProfile(widget.caseData['client_id']);
      if (clientData != null) {
        setState(() => _clientProfile = clientData);
      }

      // Cargar mensajes del caso
      final messages = await SupabaseService.getChatMessages(widget.caseData['id']);
      setState(() => _messages = messages);
    } catch (e) {
      print('Error cargando detalles del caso: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(widget.caseData['created_at']);
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
    
    // Obtener datos de la propuesta aceptada
    final List<dynamic> proposals = widget.caseData['proposals'] ?? [];
    final Map<String, dynamic>? acceptedProposal = proposals.isNotEmpty ? proposals.first : null;
    final double fee = acceptedProposal?['proposed_fee']?.toDouble() ?? widget.caseData['budget']?.toDouble() ?? 0.0;
    final int estimatedDays = acceptedProposal?['estimated_days'] ?? 30;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalles del Caso',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Eliminamos el botón de mensaje del AppBar
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCaseHeader(),
                  const SizedBox(height: 20),
                  _buildCaseInfo(fee, estimatedDays, formattedDate),
                  const SizedBox(height: 20),
                  _buildStatusUpdateSection(),
                  const SizedBox(height: 20),
                  _buildClientInfo(),
                  const SizedBox(height: 20),
                  _buildMessagesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCaseHeader() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
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
                Icon(
                  Icons.work_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.caseData['title'] ?? 'Sin título',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.caseData['category'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.caseData['category'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseInfo(double fee, int estimatedDays, String formattedDate) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Caso',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Descripción', widget.caseData['description'] ?? 'Sin descripción'),
            const SizedBox(height: 12),
            _buildInfoRow('Tarifa Acordada', '\$ ${_formatCurrency(fee)} COP'),
            const SizedBox(height: 12),
            _buildInfoRow('Tiempo Estimado', '$estimatedDays días'),
            const SizedBox(height: 12),
            _buildInfoRow('Fecha de Creación', formattedDate),
            const SizedBox(height: 12),
            _buildInfoRow('Estado', _getStatusText(widget.caseData['status'])),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo() {
    if (_clientProfile == null) {
      return Card(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Cliente',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Cliente',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (_clientProfile!['full_name'] ?? 'Cliente')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _clientProfile!['full_name'] ?? 'Sin nombre',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _clientProfile!['email'] ?? 'Sin email',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (_clientProfile!['phone'] != null)
                        Text(
                          _clientProfile!['phone'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Mensajes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_messages.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_messages.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 40,
                      color: Colors.white60,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin mensajes aún',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _messages.take(3).map((message) {
                  final isFromLawyer = message['sender_type'] == 'lawyer';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isFromLawyer ? AppColors.primary : Colors.blue,
                          child: Icon(
                            isFromLawyer ? Icons.gavel : Icons.person,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message['message'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (_messages.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    '+${_messages.length - 3} mensajes más',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    final currentStatus = widget.caseData['status'] ?? 'assigned';
    
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualizar Estado',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusRadioOption('assigned', 'En preparación', Colors.green, currentStatus),
            const SizedBox(height: 12),
            _buildStatusRadioOption('active', 'En trámite', Colors.orange, currentStatus),
            const SizedBox(height: 12),
            _buildStatusRadioOption('completed', 'Terminado', Colors.purple, currentStatus),
            const SizedBox(height: 12),
            _buildStatusRadioOption('cancelled', 'Cancelado', Colors.red, currentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRadioOption(String status, String label, Color color, String currentStatus) {
    final bool isCurrentStatus = currentStatus == status;
    
    return InkWell(
      onTap: isCurrentStatus ? null : () => _confirmStatusUpdate(status, label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentStatus ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentStatus ? color : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCurrentStatus ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
              child: isCurrentStatus
                  ? Icon(Icons.circle, color: color, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isCurrentStatus ? color : Colors.white,
                      fontWeight: isCurrentStatus ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  if (isCurrentStatus)
                    Text(
                      'Estado actual',
                      style: GoogleFonts.poppins(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (!isCurrentStatus)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'open':
        return 'Abierto';
      case 'assigned':
        return 'En preparación';
      case 'active':
        return 'En trámite';
      case 'completed':
        return 'Terminado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  void _confirmStatusUpdate(String newStatus, String statusLabel) {
    // Si es cancelado, mostrar diálogo especial para pedir motivo
    if (newStatus == 'cancelled') {
      _showCancellationReasonDialog(newStatus, statusLabel);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Confirmar Cambio',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de cambiar el estado del caso a "$statusLabel"?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => _performStatusUpdate(newStatus, statusLabel, null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Confirmar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancellationReasonDialog(String newStatus, String statusLabel) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Motivo de Cancelación',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por favor, explica el motivo por el cual se cancela este caso. Este mensaje se enviará al cliente.',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe el motivo de la cancelación...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Por favor escribe un motivo para la cancelación',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final reason = reasonController.text.trim();
              reasonController.dispose();
              Navigator.pop(context);
              _performStatusUpdate(newStatus, statusLabel, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Cancelar Caso',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performStatusUpdate(String newStatus, String statusLabel, String? cancellationReason) async {
    Navigator.pop(context); // Cerrar diálogo de confirmación
    
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Actualizando estado...',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Actualizar el estado en la base de datos
      await SupabaseService.updateCaseStatus(widget.caseData['id'], newStatus);
      
      // Actualizar el progreso local según el estado
      int newProgress = 0;
      if (newStatus == 'completed') {
        newProgress = 100;
      } else if (newStatus == 'assigned') {
        newProgress = 0;
      } else if (newStatus == 'active') {
        newProgress = widget.caseData['progress'] ?? 50;
        if (newProgress == 0 || newProgress == 100) {
          newProgress = 50;
        }
      }
      
      // Si hay motivo de cancelación, enviar mensaje al chat
      if (cancellationReason != null && cancellationReason.isNotEmpty) {
        await _sendCancellationMessage(cancellationReason);
      }
      
      Navigator.pop(context); // Cerrar indicador de carga
      
      // Mostrar éxito y actualizar la interfaz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'cancelled' 
              ? 'Caso cancelado y notificación enviada al cliente'
              : 'Estado actualizado a "$statusLabel" exitosamente',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Actualizar el estado y progreso local, y refrescar la pantalla
      setState(() {
        widget.caseData['status'] = newStatus;
        widget.caseData['progress'] = newProgress;
      });
      
    } catch (e) {
      Navigator.pop(context); // Cerrar indicador de carga
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar el estado: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendCancellationMessage(String reason) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final message = 'El caso ha sido cancelado. Motivo: $reason';

      await Supabase.instance.client.from('chat_messages').insert({
        'case_id': widget.caseData['id'],
        'sender_id': user.id,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Recargar mensajes si están en la vista
      if (mounted) {
        _loadCaseDetails();
      }
    } catch (e) {
      print('Error al enviar mensaje de cancelación: $e');
    }
  }
}