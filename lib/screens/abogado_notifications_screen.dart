import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbogadoNotificationsScreen extends StatelessWidget {
  const AbogadoNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23), // Cambiado a negro
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBB8B30),
            const Color(0xFFBB8B30).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Mantente al día con tu práctica legal',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '0 nuevas',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFBB8B30).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 64,
                color: Color(0xFFBB8B30),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay notificaciones',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando tengas nuevas propuestas, mensajes de clientes o actualizaciones de casos, aparecerán aquí.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildNotificationTypes(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypes() {
    final types = [
      {
        'title': 'Nuevas propuestas',
        'icon': Icons.send,
        'color': const Color(0xFF2196F3),
        'description': 'Respuestas a tus postulaciones',
      },
      {
        'title': 'Mensajes',
        'icon': Icons.message,
        'color': const Color(0xFF4CAF50),
        'description': 'Comunicación con clientes',
      },
      {
        'title': 'Casos',
        'icon': Icons.folder,
        'color': const Color(0xFFFF9800),
        'description': 'Actualizaciones de casos',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de notificaciones',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        ...types.map((type) => _buildNotificationTypeCard(
          type['title'] as String,
          type['icon'] as IconData,
          type['color'] as Color,
          type['description'] as String,
        )),
      ],
    );
  }

  Widget _buildNotificationTypeCard(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
