import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../widgets/connection_status_badge.dart';
import 'lawyer_search_screen_supabase.dart';
import 'ai_legal_chat_screen.dart';
import 'legal_forms_screen.dart';
import 'form_screens/civil_form_screen.dart';
import 'form_screens/penal_form_screen.dart';
import 'form_screens/laboral_form_screen.dart';
import 'form_screens/comercial_form_screen.dart';
import 'form_screens/administrativo_form_screen.dart';
import 'form_screens/constitucional_form_screen.dart';
import 'form_screens/familia_form_screen.dart';
import 'form_screens/tributario_form_screen.dart';

class HomeScreenSupabase extends StatefulWidget {
  const HomeScreenSupabase({super.key});

  @override
  State<HomeScreenSupabase> createState() => _HomeScreenSupabaseState();
}

class _HomeScreenSupabaseState extends State<HomeScreenSupabase> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images_logo/imagen_fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsSection(),
              _buildAILegalChatCard(),
              _buildLegalFormsSection(),
              _buildSearchSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.9),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Image.asset(
                AppImages.logoLogic,
                width: 107,
                height: 107,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.psychology,
                    size: 77,
                    color: AppColors.onPrimary,
                  );
                },
              ),
              const Spacer(),
              const ConnectionStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('500+', 'Abogados', Icons.people),
          _buildStatItem('1200+', 'Casos', Icons.cases),
          _buildStatItem('95%', 'Satisfacción', Icons.star),
          _buildStatItem('24/7', 'Soporte', Icons.support_agent),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buscar Abogados',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                color: Colors.black87, // Texto negro visible
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por especialidad, nombre o ubicación...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LawyerSearchScreenSupabase(),
                      ),
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSubmitted: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LawyerSearchScreenSupabase(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAILegalChatCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              _openAIChatScreen();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: AppColors.onPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consulta Jurídica con IA',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Obtén respuestas inmediatas sobre tutelas, sucesiones, derecho civil y más',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.onPrimary.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca para comenzar →',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAIChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AILegalChatScreen(),
      ),
    );
  }

  Widget _buildLegalFormsSection() {
    final legalForms = [

      {
        'title': 'Derecho Penal',
        'description': 'Defensa penal y procesos criminales',
        'icon': Icons.security,
        'color': Colors.red,
        'type': 'penal'
      },
      {
        'title': 'Derecho Laboral',
        'description': 'Protección de derechos laborales',
        'icon': Icons.work,
        'color': Colors.green,
        'type': 'laboral'
      },
      {
        'title': 'Derecho Comercial',
        'description': 'Empresas, sociedades y comercio',
        'icon': Icons.business,
        'color': Colors.orange,
        'type': 'comercial'
      },
      {
        'title': 'Derecho Administrativo',
        'description': 'Actos administrativos y contratación pública',
        'icon': Icons.account_balance,
        'color': Colors.indigo,
        'type': 'administrativo'
      },
      {
        'title': 'Derecho Constitucional',
        'description': 'Derechos fundamentales y tutelas',
        'icon': Icons.balance,
        'color': Colors.teal,
        'type': 'constitucional'
      },
      {
        'title': 'Derecho de Familia',
        'description': 'Divorcios, alimentos y custodia',
        'icon': Icons.family_restroom,
        'color': Colors.purple,
        'type': 'familia'
      },
      {
        'title': 'Derecho Civil',
        'description': 'Contratos, propiedad y responsabilidad',
        'icon': Icons.gavel,
        'color': Colors.blueGrey,
        'type': 'civil'
      },
      {
        'title': 'Derecho Tributario',
        'description': 'Impuestos, tributación y DIAN',
        'icon': Icons.account_balance_wallet,
        'color': Colors.brown,
        'type': 'tributario'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publica tu Caso',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Diligencia un formulario para que un abogado conozca tu caso',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: legalForms.length,
            itemBuilder: (context, index) {
              final form = legalForms[index];
              return _buildLegalFormCard(form);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalFormCard(Map<String, dynamic> form) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: (form['color'] as Color).withOpacity(0.1),
            child: Icon(
              form['icon'] as IconData,
              color: form['color'] as Color,
              size: 20,
            ),
          ),
          title: Text(
            form['title'] as String,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            form['description'] as String,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 14,
          ),
          onTap: () {
            _navigateToSpecificForm(form['type'] as String);
          },
        ),
      ),
    );
  }

  void _navigateToSpecificForm(String formType) {
    Widget targetScreen;
    
    switch (formType) {

      case 'penal':
        targetScreen = const PenalFormScreen();
        break;
      case 'laboral':
        targetScreen = const LaboralFormScreen();
        break;
      case 'comercial':
        targetScreen = const ComercialFormScreen();
        break;
      case 'administrativo':
        targetScreen = const AdministrativoFormScreen();
        break;
      case 'constitucional':
        targetScreen = const ConstitucionalFormScreen();
        break;
      case 'familia':
        targetScreen = const FamiliaFormScreen();
        break;
      case 'civil':
        targetScreen = const CivilFormScreen();
        break;
      case 'tributario':
        targetScreen = const TributarioFormScreen();
        break;
      default:
        // Si no encuentra el formulario específico, va a la pantalla de selección
        targetScreen = const LegalFormsScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }
}
