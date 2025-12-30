import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/case.dart';
import '../screens/lawyer_chat_screen.dart';

class CaseCard extends StatelessWidget {
  final LegalCase legalCase;
  final VoidCallback onTap;

  const CaseCard({
    super.key,
    required this.legalCase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLawyer = legalCase.assignedLawyer != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con área legal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: legalCase.areaColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: legalCase.areaColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    legalCase.areaIcon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        legalCase.areaName,
                        style: TextStyle(
                          color: legalCase.areaColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        legalCase.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Contador de ofertas si no tiene abogado
                if (!hasLawyer && legalCase.offersCount > 0)
                  _buildOffersButton(),
              ],
            ),
          ),
          
          // Información del caso
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del abogado si está asignado
                if (hasLawyer) ...[
                  _buildLawyerInfo(),
                  const SizedBox(height: 16),
                  _buildProgressInfo(),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ] else ...[
                  Text(
                    legalCase.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _buildPendingCaseActions(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${legalCase.offersCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'ofertas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerInfo() {
    final lawyer = legalCase.assignedLawyer!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            child: lawyer.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      lawyer.profileImage!,
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                    ),
                  )
                : Text(
                    lawyer.firstName[0] + lawyer.lastName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${lawyer.rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lawyer.fullName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${lawyer.location} / ${lawyer.typeName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Especialidad: ${lawyer.specialtiesText}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              legalCase.statusName,
              style: TextStyle(
                color: legalCase.statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Tiempo transcurrido: ${legalCase.daysElapsed} días',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Barra de progreso
        Row(
          children: [
            // Círculo de progreso
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: legalCase.progressPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: legalCase.statusColor,
                    strokeWidth: 4,
                  ),
                  Center(
                    child: Text(
                      '${legalCase.progressPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: legalCase.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Timeline
            Expanded(
              child: Column(
                children: legalCase.updates.map((update) {
                  return _buildTimelineItem(update);
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(CaseUpdate update) {
    final formatter = DateFormat('d \'de\' MMMM', 'es_ES');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: update.status == legalCase.status 
                  ? legalCase.statusColor 
                  : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusName(update.status),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            formatter.format(update.date),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusName(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return 'Pendiente';
      case CaseStatus.preparation:
        return 'En preparación';
      case CaseStatus.inProgress:
        return 'En trámite';
      case CaseStatus.completed:
        return 'Terminado';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('Ver detalles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B6B6B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            // Abrir chat con el abogado
            if (legalCase.assignedLawyer != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LawyerChatScreen(
                    lawyer: legalCase.assignedLawyer!,
                    caseTitle: legalCase.title,
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.chat_bubble, size: 18),
          label: const Text('Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCaseActions() {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B6B6B),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(double.infinity, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Ver ofertas recibidas',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
