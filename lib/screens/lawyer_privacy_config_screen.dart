import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

class LawyerPrivacyConfigScreen extends StatefulWidget {
  const LawyerPrivacyConfigScreen({super.key});

  @override
  State<LawyerPrivacyConfigScreen> createState() => _LawyerPrivacyConfigScreenState();
}

class _LawyerPrivacyConfigScreenState extends State<LawyerPrivacyConfigScreen> {
  bool _profileVisible = true;
  bool _contactInfoVisible = false;
  bool _specializationsVisible = true;
  bool _experienceVisible = true;
  bool _ratingVisible = true;
  bool _allowDirectContact = true;
  bool _requireIntroduction = false;
  bool _shareDataAnalytics = true;
  bool _marketingEmails = false;
  
  String _profileVisibility = 'public';
  String _contactPreference = 'platform';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId != null) {
        // Verificar si es estudiante
        if (authProvider.isStudent) {
          // Para estudiantes, configurar privacidad básica
          setState(() {
            _profileVisible = true;
            _contactInfoVisible = false;
            _allowDirectContact = true;
            _ratingVisible = false; // Los estudiantes no tienen calificaciones
            _profileVisibility = 'public';
            _isLoading = false;
          });
          return;
        }
        
        final lawyerProfile = await SupabaseService.getLawyerProfile(authProvider.userId!);
        
        if (lawyerProfile != null && mounted) {
          setState(() {
            _profileVisible = lawyerProfile['profile_visible'] ?? true;
            _contactInfoVisible = lawyerProfile['show_contact_info'] ?? false;
            _allowDirectContact = lawyerProfile['allow_direct_messages'] ?? true;
            _ratingVisible = lawyerProfile['show_reviews'] ?? true;
            _profileVisibility = lawyerProfile['privacy_level'] ?? 'public';
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

  Future<void> _savePrivacySettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await SupabaseService.updateLawyerPrivacySettings(
        lawyerId: authProvider.userId!,
        profileVisible: _profileVisible,
        showContactInfo: _contactInfoVisible,
        allowDirectMessages: _allowDirectContact,
        showReviews: _ratingVisible,
        privacyLevel: _profileVisibility,
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
          'Privacidad y Seguridad',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Visibilidad del Perfil', Icons.visibility),
            _buildProfileVisibility(),
            
            const SizedBox(height: 30),
            
            _buildSectionHeader('Información Compartida', Icons.share),
            _buildDataSharing(),
            
            const SizedBox(height: 30),
            
            _buildSectionHeader('Preferencias de Contacto', Icons.contact_phone),
            _buildContactPreferences(),
            
            const SizedBox(height: 30),
            
            _buildSectionHeader('Seguridad y Datos', Icons.security),
            _buildSecuritySettings(),
            
            const SizedBox(height: 40),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePrivacySettings,
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
          Text(title, style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProfileVisibility() {
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
            value: _profileVisibility,
            decoration: InputDecoration(
              labelText: 'Visibilidad del Perfil',
              labelStyle: GoogleFonts.poppins(color: Colors.white70),
            ),
            dropdownColor: AppColors.surface,
            style: GoogleFonts.poppins(color: Colors.white),
            items: [
              DropdownMenuItem(value: 'public', child: Text('Público')),
              DropdownMenuItem(value: 'verified_only', child: Text('Solo usuarios verificados')),
              DropdownMenuItem(value: 'private', child: Text('Privado')),
            ],
            onChanged: (v) => setState(() => _profileVisibility = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Mostrar información de contacto', style: GoogleFonts.poppins(color: Colors.white)),
            value: _contactInfoVisible,
            onChanged: (v) => setState(() => _contactInfoVisible = v),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text('Mostrar especialidades', style: GoogleFonts.poppins(color: Colors.white)),
            value: _specializationsVisible,
            onChanged: (v) => setState(() => _specializationsVisible = v),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text('Mostrar años de experiencia', style: GoogleFonts.poppins(color: Colors.white)),
            value: _experienceVisible,
            onChanged: (v) => setState(() => _experienceVisible = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSharing() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text('Compartir datos para análisis', style: GoogleFonts.poppins(color: Colors.white)),
            subtitle: Text('Ayuda a mejorar la plataforma', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            value: _shareDataAnalytics,
            onChanged: (v) => setState(() => _shareDataAnalytics = v),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text('Recibir emails de marketing', style: GoogleFonts.poppins(color: Colors.white)),
            value: _marketingEmails,
            onChanged: (v) => setState(() => _marketingEmails = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildContactPreferences() {
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
            value: _contactPreference,
            decoration: InputDecoration(
              labelText: 'Método de contacto preferido',
              labelStyle: GoogleFonts.poppins(color: Colors.white70),
            ),
            dropdownColor: AppColors.surface,
            style: GoogleFonts.poppins(color: Colors.white),
            items: [
              DropdownMenuItem(value: 'platform', child: Text('Solo a través de la plataforma')),
              DropdownMenuItem(value: 'email', child: Text('Email directo')),
              DropdownMenuItem(value: 'phone', child: Text('Teléfono')),
              DropdownMenuItem(value: 'any', child: Text('Cualquier método')),
            ],
            onChanged: (v) => setState(() => _contactPreference = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Permitir contacto directo', style: GoogleFonts.poppins(color: Colors.white)),
            value: _allowDirectContact,
            onChanged: (v) => setState(() => _allowDirectContact = v),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text('Requerir presentación formal', style: GoogleFonts.poppins(color: Colors.white)),
            subtitle: Text('Los clientes deben presentarse antes del contacto', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            value: _requireIntroduction,
            onChanged: (v) => setState(() => _requireIntroduction = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppColors.primary),
            title: Text('Cambiar Contraseña', style: GoogleFonts.poppins(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(color: Colors.white30),
          ListTile(
            leading: Icon(Icons.security, color: AppColors.primary),
            title: Text('Verificación en Dos Pasos', style: GoogleFonts.poppins(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
            onTap: () => _showTwoFactorDialog(),
          ),
          const Divider(color: Colors.white30),
          ListTile(
            leading: Icon(Icons.download, color: AppColors.primary),
            title: Text('Descargar Mis Datos', style: GoogleFonts.poppins(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
            onTap: () => _requestDataExport(),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Cambiar Contraseña',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    prefixIcon: Icon(Icons.lock_reset, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una nueva contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    prefixIcon: Icon(Icons.lock_clock, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La contraseña debe tener al menos 6 caracteres',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (formKey.currentState!.validate()) {
                  setState(() => isLoading = true);
                  
                  try {
                    // Simular cambio de contraseña - aquí integrarías con Supabase
                    await Future.delayed(const Duration(seconds: 2));
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Contraseña actualizada exitosamente', style: GoogleFonts.poppins()),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cambiar contraseña: $e', style: GoogleFonts.poppins()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Cambiar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  void _showTwoFactorDialog() {
    bool isTwoFactorEnabled = false; // En una app real, esto vendría del estado del usuario
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(Icons.security, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Verificación en Dos Pasos',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Verificación en Dos Pasos',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: isTwoFactorEnabled,
                          onChanged: isLoading ? null : (value) {
                            setState(() => isTwoFactorEnabled = value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isTwoFactorEnabled 
                        ? 'La verificación en dos pasos está ACTIVADA. Tu cuenta está protegida con una capa adicional de seguridad.'
                        : 'Agrega una capa extra de seguridad a tu cuenta. Se requerirá un código de verificación además de tu contraseña.',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isTwoFactorEnabled) ...[
                Text(
                  'Métodos de Verificación Disponibles:',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTwoFactorMethod(
                  'SMS al teléfono',
                  'Recibe códigos por mensaje de texto',
                  Icons.sms,
                  true,
                ),
                const SizedBox(height: 8),
                _buildTwoFactorMethod(
                  'Aplicación Autenticadora',
                  'Google Authenticator, Authy, etc.',
                  Icons.smartphone,
                  false,
                ),
                const SizedBox(height: 8),
                _buildTwoFactorMethod(
                  'Email de Verificación',
                  'Códigos enviados a tu correo',
                  Icons.email,
                  true,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tu cuenta solo está protegida con contraseña. Activa 2FA para mayor seguridad.',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            if (!isTwoFactorEnabled)
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true);
                  
                  try {
                    // Simular configuración de 2FA
                    await Future.delayed(const Duration(seconds: 2));
                    setState(() => isTwoFactorEnabled = true);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.security, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Verificación en dos pasos activada', style: GoogleFonts.poppins()),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al configurar 2FA: $e', style: GoogleFonts.poppins()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Activar 2FA', style: GoogleFonts.poppins()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorMethod(String title, String subtitle, IconData icon, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled 
          ? AppColors.success.withValues(alpha: 0.1) 
          : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? AppColors.success : Colors.white30,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon, 
            color: isEnabled ? AppColors.success : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isEnabled ? AppColors.success : Colors.white30,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _requestDataExport() {
    bool includeProfile = true;
    bool includeCases = true;
    bool includeMessages = true;
    bool includePayments = false;
    bool includeActivity = true;
    String exportFormat = 'json';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(Icons.download, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Descargar Mis Datos',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selecciona qué datos deseas incluir en tu exportación',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Datos a Incluir:',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDataOption(
                  'Perfil Profesional',
                  'Información personal, especialidades, certificaciones',
                  Icons.person,
                  includeProfile,
                  (value) => setState(() => includeProfile = value),
                ),
                _buildDataOption(
                  'Casos y Consultas',
                  'Historial de casos, propuestas enviadas y recibidas',
                  Icons.gavel,
                  includeCases,
                  (value) => setState(() => includeCases = value),
                ),
                _buildDataOption(
                  'Mensajes y Chat',
                  'Conversaciones con clientes y colegas',
                  Icons.message,
                  includeMessages,
                  (value) => setState(() => includeMessages = value),
                ),
                _buildDataOption(
                  'Información de Pagos',
                  'Historial de transacciones y facturación',
                  Icons.payment,
                  includePayments,
                  (value) => setState(() => includePayments = value),
                ),
                _buildDataOption(
                  'Actividad en la Plataforma',
                  'Logs de acceso, configuraciones, preferencias',
                  Icons.history,
                  includeActivity,
                  (value) => setState(() => includeActivity = value),
                ),
                const SizedBox(height: 20),
                Text(
                  'Formato de Exportación:',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: exportFormat,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  dropdownColor: AppColors.surface,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                  items: [
                    DropdownMenuItem(
                      value: 'json',
                      child: Row(
                        children: [
                          Icon(Icons.code, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text('JSON (Recomendado)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'csv',
                      child: Row(
                        children: [
                          Icon(Icons.table_chart, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text('CSV (Excel)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text('PDF (Documento)'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => exportFormat = value!),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule, color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La generación del archivo puede tomar varios minutos. Te enviaremos un email cuando esté listo.',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (!includeProfile && !includeCases && !includeMessages && !includePayments && !includeActivity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selecciona al menos un tipo de dato', style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                setState(() => isLoading = true);
                
                try {
                  // Simular proceso de exportación
                  await Future.delayed(const Duration(seconds: 3));
                  
                  Navigator.pop(context);
                  
                  // Mostrar dialog de confirmación
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text('Exportación Iniciada', style: GoogleFonts.poppins(color: Colors.white)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tu solicitud de exportación ha sido procesada exitosamente.',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.email, color: AppColors.success, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Recibirás un email con el enlace de descarga en los próximos 15-30 minutos.',
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.timer, color: AppColors.success, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'El enlace será válido por 48 horas.',
                                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
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
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: Text('Entendido', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al procesar exportación: $e', style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } finally {
                  setState(() => isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Exportar Datos', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOption(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
        activeColor: AppColors.primary,
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    );
  }
}