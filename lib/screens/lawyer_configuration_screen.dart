import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../utils/app_colors.dart';
import 'lawyer_profile_config_screen.dart';
import 'lawyer_schedule_config_screen.dart';
import 'lawyer_notification_config_screen.dart';
import 'lawyer_pricing_config_screen.dart';
import 'lawyer_privacy_config_screen.dart';

class LawyerConfigurationScreen extends StatelessWidget {
  const LawyerConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Configuración Professional',
          style: GoogleFonts.poppins(
            color: AppColors.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del usuario
                _buildUserHeader(authProvider),
                
                const SizedBox(height: 30),
                
                // Secciones de configuración
                _buildConfigSection(
                  context,
                  'Perfil Profesional',
                  'Datos personales, especialidades, experiencia',
                  Icons.person_outline,
                  AppColors.primary,
                  () => _navigateToScreen(context, const LawyerProfileConfigScreen()),
                ),
                
                const SizedBox(height: 16),
                
                _buildConfigSection(
                  context,
                  'Horarios de Disponibilidad',
                  'Configura tus horarios de trabajo y citas',
                  Icons.schedule,
                  AppColors.primaryLight,
                  () => _navigateToScreen(context, const LawyerScheduleConfigScreen()),
                ),
                
                const SizedBox(height: 16),
                
                _buildConfigSection(
                  context,
                  'Notificaciones',
                  'Preferencias de notificaciones y alertas',
                  Icons.notifications_outlined,
                  AppColors.success,
                  () => _navigateToScreen(context, const LawyerNotificationConfigScreen()),
                ),
                
                const SizedBox(height: 16),
                
                _buildConfigSection(
                  context,
                  'Precios y Servicios',
                  'Tarifas, paquetes y métodos de pago',
                  Icons.attach_money,
                  AppColors.warning,
                  () => _navigateToScreen(context, const LawyerPricingConfigScreen()),
                ),
                
                const SizedBox(height: 16),
                
                _buildConfigSection(
                  context,
                  'Privacidad y Seguridad',
                  'Configuración de privacidad y datos',
                  Icons.security,
                  AppColors.error,
                  () => _navigateToScreen(context, const LawyerPrivacyConfigScreen()),
                ),
                
                const SizedBox(height: 30),
                
                // Botones de acción
                _buildActionButtons(context, authProvider),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/imagen_fondo.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.goldShadow],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage: authProvider.userAvatar != null
                ? NetworkImage(authProvider.userAvatar!)
                : null,
            child: authProvider.userAvatar == null
                ? Text(
                    authProvider.userName?.substring(0, 1).toUpperCase() ?? 'A',
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
                  authProvider.userName ?? 'Abogado',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  authProvider.userEmail ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.gavel,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        // Botón de cerrar sesión
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _logout(context, authProvider),
            icon: const Icon(Icons.logout),
            label: Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _logout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cerrar Sesión',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Cerrar Sesión',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

}