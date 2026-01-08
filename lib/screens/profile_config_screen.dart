import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider_supabase.dart';
import '../providers/user_config_provider.dart';
import '../utils/app_colors.dart';
import 'personal_info_screen.dart';
import 'payment_methods_screen.dart';
import 'payment_history_screen.dart';
import 'billing_info_screen.dart';
import 'security_settings_screen.dart';
import 'help_center_screen.dart';

class ProfileConfigScreen extends StatefulWidget {
  const ProfileConfigScreen({Key? key}) : super(key: key);

  @override
  State<ProfileConfigScreen> createState() => _ProfileConfigScreenState();
}

class _ProfileConfigScreenState extends State<ProfileConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildUserProfileHeader(),
                _buildAccountSection(),
                _buildPreferencesSection(),
                _buildPaymentSection(),
                _buildNotificationSection(),
                _buildLegalSection(),
                _buildSupportSection(),
                _buildSignOutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    return Consumer2<AuthProvider, UserConfigProvider>(
      builder: (context, authProvider, configProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: configProvider.isPremium
                        ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                        : [Colors.grey, Colors.grey.withOpacity(0.8)],
                  ),
                ),
                child: Icon(
                  configProvider.isPremium ? Icons.verified_user : Icons.person,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      configProvider.fullName.isNotEmpty
                          ? configProvider.fullName
                          : authProvider.user?.email ?? 'Usuario',
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
                          configProvider.isPremium ? Icons.star : Icons.person_outline,
                          size: 16,
                          color: configProvider.isPremium ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          configProvider.membershipDisplayName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: configProvider.isPremium ? AppColors.primary : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      configProvider.membershipStatusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    if (!configProvider.isPremium) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showPremiumUpgrade(configProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: Text(
                            'Actualizar a Premium',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return Consumer<UserConfigProvider>(
      builder: (context, configProvider, child) {
        return _buildSection(
          title: 'Mi Cuenta',
          icon: Icons.account_circle,
          children: [
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Información Personal',
              subtitle: configProvider.fullName.isNotEmpty 
                  ? configProvider.fullName 
                  : 'Nombre, teléfono, dirección',
              onTap: () => _showPersonalInfoScreen(),
            ),
            _buildSettingItem(
              icon: Icons.security,
              title: 'Seguridad y Privacidad',
              subtitle: 'Contraseña, verificación en dos pasos',
              onTap: () => _showSecuritySettings(),
            ),
            _buildSettingItem(
              icon: Icons.location_on_outlined,
              title: 'Región y Ciudad',
              subtitle: configProvider.selectedRegion,
              onTap: () => _showRegionSelector(configProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreferencesSection() {
    return Consumer<UserConfigProvider>(
      builder: (context, configProvider, child) {
        return _buildSection(
          title: 'Preferencias',
          icon: Icons.settings,
          children: [
            _buildSettingItem(
              icon: Icons.language,
              title: 'Idioma',
              subtitle: configProvider.selectedLanguage,
              onTap: () => _showLanguageSelector(configProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      title: 'Pagos y Facturación',
      icon: Icons.payment,
      children: [
        _buildSettingItem(
          icon: Icons.credit_card,
          title: 'Métodos de Pago',
          subtitle: 'Tarjetas, PSE, efectivo',
          onTap: () => _showPaymentMethods(),
        ),
        _buildSettingItem(
          icon: Icons.receipt_long,
          title: 'Historial de Pagos',
          subtitle: 'Ver transacciones realizadas',
          onTap: () => _showPaymentHistory(),
        ),
        _buildSettingItem(
          icon: Icons.account_balance_wallet,
          title: 'Facturación',
          subtitle: 'Datos de facturación fiscal',
          onTap: () => _showBillingInfo(),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Consumer<UserConfigProvider>(
      builder: (context, configProvider, child) {
        return _buildSection(
          title: 'Notificaciones',
          icon: Icons.notifications,
          children: [
            _buildSwitchItem(
              icon: Icons.notifications_active,
              title: 'Notificaciones',
              subtitle: 'Recibir notificaciones generales',
              value: configProvider.notificationsEnabled,
              onChanged: (value) async {
                await configProvider.setNotificationsEnabled(value);
              },
            ),
            _buildSwitchItem(
              icon: Icons.email,
              title: 'Notificaciones por Email',
              subtitle: 'Recibir emails informativos',
              value: configProvider.emailNotifications,
              onChanged: (value) async {
                await configProvider.setEmailNotifications(value);
              },
            ),
            _buildSwitchItem(
              icon: Icons.phone_android,
              title: 'Notificaciones Push',
              subtitle: 'Alertas en tiempo real',
              value: configProvider.pushNotifications,
              onChanged: (value) async {
                await configProvider.setPushNotifications(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegalSection() {
    return _buildSection(
      title: 'Legal y Privacidad',
      icon: Icons.gavel,
      children: [
        _buildSettingItem(
          icon: Icons.description,
          title: 'Términos y Condiciones',
          subtitle: 'Condiciones de uso de la aplicación',
          onTap: () => _showTermsAndConditions(),
        ),
        _buildSettingItem(
          icon: Icons.privacy_tip,
          title: 'Política de Privacidad',
          subtitle: 'Cómo manejamos tus datos',
          onTap: () => _showPrivacyPolicy(),
        ),
        _buildSettingItem(
          icon: Icons.cookie,
          title: 'Política de Cookies',
          subtitle: 'Uso de cookies y tecnologías similares',
          onTap: () => _showCookiePolicy(),
        ),
        _buildSettingItem(
          icon: Icons.info_outline,
          title: 'Acerca de Logic Lex',
          subtitle: 'Versión 1.0.0 - © 2025',
          onTap: () => _showAboutDialog(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Soporte y Ayuda',
      icon: Icons.help,
      children: [
        _buildSettingItem(
          icon: Icons.help_center,
          title: 'Centro de Ayuda',
          subtitle: 'Preguntas frecuentes y guías',
          onTap: () => _showHelpCenter(),
        ),
        _buildSettingItem(
          icon: Icons.contact_support,
          title: 'Contactar Soporte',
          subtitle: 'Obtener ayuda especializada',
          onTap: () => _showContactSupport(),
        ),
        _buildSettingItem(
          icon: Icons.share,
          title: 'Compartir App',
          subtitle: 'Recomienda Logic Lex a otros',
          onTap: () => _shareApp(),
        ),
        _buildSettingItem(
          icon: Icons.star_rate,
          title: 'Calificar App',
          subtitle: 'Ayúdanos a mejorar',
          onTap: () => _showRateApp(),
        ),
      ],
    );
  }

  Widget _buildSignOutSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            color: Colors.red,
            onTap: () => _confirmSignOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(UserConfigProvider configProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar Idioma',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ...['Español', 'English', 'Português'].map((language) {
                return ListTile(
                  title: Text(
                    language,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  trailing: configProvider.selectedLanguage == language
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await configProvider.setLanguage(language);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showRegionSelector(UserConfigProvider configProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar Región',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ...[
                  'Bogotá, Colombia',
                  'Medellín, Colombia', 
                  'Cali, Colombia',
                  'Barranquilla, Colombia',
                  'Cartagena, Colombia'
                ].map((region) {
                  return ListTile(
                    title: Text(
                      region,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    trailing: configProvider.selectedRegion == region
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      await configProvider.setRegion(region);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPersonalInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoScreen(),
      ),
    );
  }

  void _showSecuritySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecuritySettingsScreen(),
      ),
    );
  }

  void _showPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodsScreen(),
      ),
    );
  }

  void _showPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentHistoryScreen(),
      ),
    );
  }

  void _showBillingInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillingInfoScreen(),
      ),
    );
  }

  void _showTermsAndConditions() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TermsConditionsScreen(),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Términos y condiciones - En desarrollo')),
    );
  }

  void _showPrivacyPolicy() {
    _showSimpleScreen('Política de Privacidad', 'Protección de datos personales en Logic Lex');
  }

  void _showCookiePolicy() {
    _showSimpleScreen('Política de Cookies', 'Uso de cookies para mejorar la experiencia del usuario');
  }

  void _showAboutDialog() {
    _showSimpleScreen('Acerca de Logic Lex', 'Versión 1.0.0 - Tu asistente legal inteligente');
  }

  void _showHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpCenterScreen(),
      ),
    );
  }

  void _showContactSupport() {
    _showSimpleScreen('Contactar Soporte', 'Email: soporte@logiclex.com\nTeléfono: +57 1 234 5678');
  }

  void _shareApp() {
    _showSimpleScreen('Compartir App', '¡Recomienda Logic Lex a tus amigos y familiares!');
  }

  void _showRateApp() {
    _showSimpleScreen('Calificar App', 'Tu opinión nos ayuda a mejorar Logic Lex');
  }

  void _showSimpleScreen(String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPremiumUpgrade(UserConfigProvider configProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Actualizar a Premium',
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          '¡Desbloquea todas las funciones premium y obtén consultas ilimitadas!',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
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
            onPressed: () async {
              await configProvider.activateTrialPremium();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('¡Premium activado! Disfruta 30 días gratis'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Activar Prueba',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }
}
