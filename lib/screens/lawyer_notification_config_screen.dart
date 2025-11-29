import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

class LawyerNotificationConfigScreen extends StatefulWidget {
  const LawyerNotificationConfigScreen({super.key});

  @override
  State<LawyerNotificationConfigScreen> createState() => _LawyerNotificationConfigScreenState();
}

class _LawyerNotificationConfigScreenState extends State<LawyerNotificationConfigScreen> {
  bool _newCasesEmail = true;
  bool _newCasesPush = true;
  bool _messageEmail = false;
  bool _messagePush = true;
  bool _reminderEmail = true;
  bool _reminderPush = true;
  bool _marketingEmail = false;
  bool _marketingPush = false;
  
  String _emailFrequency = 'immediate';
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';
  bool _weekendNotifications = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId != null) {
        // Verificar si es estudiante
        if (authProvider.isStudent) {
          // Para estudiantes, configurar notificaciones básicas
          setState(() {
            _newCasesEmail = true;
            _newCasesPush = true;
            _messageEmail = false;
            _messagePush = true;
            _reminderEmail = true;
            _reminderPush = true;
            _marketingEmail = false;
            _isLoading = false;
          });
          return;
        }
        
        final lawyerProfile = await SupabaseService.getLawyerProfile(authProvider.userId!);
        
        if (lawyerProfile != null && mounted) {
          setState(() {
            _newCasesEmail = lawyerProfile['email_notifications'] ?? true;
            _newCasesPush = lawyerProfile['push_notifications'] ?? true;
            _messageEmail = lawyerProfile['message_alerts'] ?? false;
            _messagePush = lawyerProfile['message_alerts'] ?? true;
            _reminderEmail = lawyerProfile['appointment_reminders'] ?? true;
            _reminderPush = lawyerProfile['appointment_reminders'] ?? true;
            _marketingEmail = lawyerProfile['marketing_emails'] ?? false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar configuraciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await SupabaseService.updateLawyerNotificationSettings(
        lawyerId: authProvider.userId!,
        emailNotifications: _newCasesEmail,
        pushNotifications: _newCasesPush,
        messageAlerts: _messageEmail,
        appointmentReminders: _reminderEmail,
        marketingEmails: _marketingEmail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Configuraciones guardadas exitosamente',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar configuraciones: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Configuración de Notificaciones',
          style: GoogleFonts.poppins(
            color: AppColors.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Notificaciones de Casos', Icons.cases),
            _buildNotificationCard([
              _buildNotificationTile('Nuevos casos disponibles', 'Email', _newCasesEmail, (v) => setState(() => _newCasesEmail = v)),
              _buildNotificationTile('Nuevos casos disponibles', 'Push', _newCasesPush, (v) => setState(() => _newCasesPush = v)),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSectionHeader('Mensajes', Icons.message),
            _buildNotificationCard([
              _buildNotificationTile('Nuevos mensajes', 'Email', _messageEmail, (v) => setState(() => _messageEmail = v)),
              _buildNotificationTile('Nuevos mensajes', 'Push', _messagePush, (v) => setState(() => _messagePush = v)),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSectionHeader('Recordatorios', Icons.alarm),
            _buildNotificationCard([
              _buildNotificationTile('Recordatorios de citas', 'Email', _reminderEmail, (v) => setState(() => _reminderEmail = v)),
              _buildNotificationTile('Recordatorios de citas', 'Push', _reminderPush, (v) => setState(() => _reminderPush = v)),
            ]),
            
            const SizedBox(height: 20),
            
            _buildSectionHeader('Configuraciones Generales', Icons.settings),
            _buildGeneralSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNotificationTile(String title, String type, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text('$title ($type)', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildGeneralSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _emailFrequency,
            decoration: InputDecoration(
              labelText: 'Frecuencia de Email',
              labelStyle: GoogleFonts.poppins(color: Colors.white70),
            ),
            dropdownColor: AppColors.surface,
            style: GoogleFonts.poppins(color: Colors.white),
            items: [
              DropdownMenuItem(value: 'immediate', child: Text('Inmediato')),
              DropdownMenuItem(value: 'hourly', child: Text('Cada hora')),
              DropdownMenuItem(value: 'daily', child: Text('Diario')),
            ],
            onChanged: (v) => setState(() => _emailFrequency = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Notificaciones de fin de semana', style: GoogleFonts.poppins(color: Colors.white)),
            value: _weekendNotifications,
            onChanged: (v) => setState(() => _weekendNotifications = v),
            activeColor: AppColors.primary,
          ),
          
          const SizedBox(height: 40),
          
          // Botón de guardar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveNotificationSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Guardar Configuraciones',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}