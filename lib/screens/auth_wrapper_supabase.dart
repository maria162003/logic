import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart' as fonts;
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import '../providers/auth_provider_supabase.dart';
import 'lawyer_dashboard_screen_supabase.dart';
import 'client_dashboard_screen_supabase.dart';
import 'authentication_screen_supabase.dart';
import 'email_verification_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mostrar loading mientras se verifica el estado de autenticación
        if (authProvider.isLoading) {
          return _buildLoadingScreen();
        }
        
        // Si hay error
        if (authProvider.error != null) {
          return _buildErrorScreen(context, authProvider.error!);
        }
        
        // Si el usuario está autenticado
        if (authProvider.isAuthenticated) {
          // Verificar si el email está confirmado
          if (authProvider.needsEmailVerification) {
            return const EmailVerificationScreen();
          }
          
          // Si no hay perfil, mostrar loading mientras se carga
          if (authProvider.userProfile == null) {
            return _buildLoadingScreen();
          }
          
          // Redirigir según el tipo de usuario
          final userType = authProvider.userType;
          
          if (userType == 'lawyer' || userType == 'student') {
            // Estudiantes usan el mismo dashboard que abogados
            return const LawyerDashboardScreen();
          } else if (userType == 'client') {
            return const ClientDashboardScreen();
          } else {
            // Tipo de usuario no válido
            return _buildUserTypeErrorScreen(context);
          }
        }
        
        // Usuario no autenticado - mostrar pantalla de autenticación
        return const AuthenticationScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    // En Web, el video se muestra en el index.html
    // En móvil, usar el VideoLoadingScreen
    if (kIsWeb) {
      // Mostrar un contenedor negro mientras el video del index.html se reproduce
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    } else {
      // Para móvil, mostrar el video de carga
      return const _VideoLoadingScreen();
    }
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF2E5984),
              Color(0xFF3E6B94),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de error
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Título
            Text(
              'Error de Autenticación',
              style: fonts.GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Mensaje de error
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error,
                style: fonts.GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botón de retry
            ElevatedButton(
              onPressed: () {
                // Reintentar autenticación
                Provider.of<AuthProvider>(
                  context, 
                  listen: false,
                ).clearError();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A5F),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Reintentar',
                style: fonts.GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeErrorScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF2E5984),
              Color(0xFF3E6B94),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de advertencia
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_outlined,
                size: 60,
                color: Colors.orange.shade600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Título
            Text(
              'Configuración Incompleta',
              style: fonts.GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Mensaje
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tu perfil necesita ser configurado. Por favor, contacta al soporte técnico.',
                style: fonts.GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botón de cerrar sesión
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(
                  context, 
                  listen: false,
                ).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A5F),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: fonts.GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar el video de carga en dispositivos móviles
class _VideoLoadingScreen extends StatefulWidget {
  const _VideoLoadingScreen();

  @override
  State<_VideoLoadingScreen> createState() => _VideoLoadingScreenState();
}

class _VideoLoadingScreenState extends State<_VideoLoadingScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/fondocarga.mp4');
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al inicializar video de carga: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video de fondo
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          
          // Mostrar indicador de carga si el video no está listo
          if (!_isVideoInitialized)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
