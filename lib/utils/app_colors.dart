import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFDAA520); // Dorado
  static const Color primaryLight = Color(0xFFFFD700); // Dorado claro
  static const Color primaryDark = Color(0xFFB8860B); // Dorado oscuro
  
  // Colores de fondo
  static const Color background = Color(0xFF000000); // Negro
  static const Color surface = Color(0xFF1A1A1A); // Negro más claro
  static const Color surfaceVariant = Color(0xFF2D2D2D); // Gris oscuro
  
  // Colores de texto
  static const Color onPrimary = Color(0xFF000000); // Negro sobre dorado
  static const Color onBackground = Color(0xFFDAA520); // Dorado sobre negro
  static const Color onSurface = Color(0xFFFFFFFF); // Blanco sobre superficie
  static const Color onSurfaceVariant = Color(0xFFDAA520); // Dorado sobre superficie variante
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      primaryLight,
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background,
      Color(0xFF1A1A1A),
    ],
  );
  
  // Sombras doradas
  static const BoxShadow goldShadow = BoxShadow(
    color: Color(0x40DAA520),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow goldGlow = BoxShadow(
    color: Color(0x30DAA520), // Reducido de 0x60 a 0x30 para menos intensidad
    blurRadius: 12, // Reducido de 20 a 12 para menor difusión
    offset: Offset(0, 0),
  );
}
