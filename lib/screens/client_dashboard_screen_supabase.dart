import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider_supabase.dart';
import '../providers/marketplace_provider.dart';
import 'home_screen_supabase.dart';
import 'offers_list_screen_supabase.dart';
import 'my_cases_screen_supabase.dart';
import 'profile_config_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreenSupabase(), // Pantalla de Inicio con áreas legales y navegación
      OffersListScreenSupabase(
        onBackToDashboard: _navigateToHomeTab,
      ), // Ver Ofertas Recibidas - NUEVA MEJORADA
      const MyCasesScreenSupabase(), // Mis Casos
      const ProfileConfigScreen(), // Configuración Profesional
    ];
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
    
    // Cargar casos del cliente y propuestas recibidas
    await Future.wait([
      marketplaceProvider.loadMyCases(),
      marketplaceProvider.loadReceivedProposals(),
    ]);
  }

  void _navigateToHomeTab() {
    if (!mounted) return;
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(authProvider),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(AuthProvider authProvider) {
    return Consumer<MarketplaceProvider>(
      builder: (context, marketplaceProvider, child) {
        // Contar propuestas no leídas
        final unreadProposals = marketplaceProvider.receivedProposals
            .where((proposal) => proposal['status'] == 'pending')
            .length;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFBB8B30), // Dorado del tema
          unselectedItemColor: Colors.grey,
          backgroundColor: const Color(0xFF1A1B23), // Fondo oscuro
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.mail),
                  if (unreadProposals > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadProposals.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Ofertas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Casos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Config',
            ),
          ],
        );
      },
    );
  }
}
