import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import 'dart:async';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          _timer?.cancel();
          _navigateToLogin();
        }
      });
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false, // Evita overflow
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/imagen_fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // Evita overflow
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        AppColors.goldShadow,
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          AppImages.logoCompleteGold,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Logic Lex',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Icono de éxito
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 60,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título
                  Text(
                    '¡Registro Exitoso!',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descripción
                  Text(
                    '¡Tu cuenta ha sido creada exitosamente!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Información de confirmación de email
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verifica tu Email',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hemos enviado un enlace de confirmación a tu email. Haz clic en el enlace para activar tu cuenta.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Una vez confirmado tu email, podrás iniciar sesión normalmente',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.goldShadow.color,
                      ),
                      child: Text(
                        'Ir al Login ahora',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mensaje de redirección automática
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Redirección automática en $_countdown segundos',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
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
}
