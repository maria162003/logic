import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images_logo/imagen_fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de regreso
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Logo
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          AppColors.goldGlow,
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppImages.logoIconGold,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                size: 60,
                                color: AppColors.onPrimary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Título
                  Center(
                    child: Text(
                      'Bienvenido de vuelta',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Center(
                    child: Text(
                      'Inicia sesión en tu cuenta',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Campo de email
                  _buildEmailField(),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de contraseña
                  _buildPasswordField(),
                  
                  const SizedBox(height: 16),
                  
                  // Recordarme y olvidé contraseña
                  _buildRememberAndForgot(),
                  
                  const SizedBox(height: 32),
                  
                  // Botón de inicio de sesión
                  _buildLoginButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  _buildDivider(),
                  
                  const SizedBox(height: 24),
                  
                  // Enlace a registro
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'tu.email@ejemplo.com',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu email';
            }
            if (!value.contains('@')) {
              return 'Por favor ingresa un email válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tu contraseña',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: Colors.white,
              checkColor: const Color(0xFF1E3A5F),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
            ),
            Text(
              'Recordarme',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _showForgotPasswordDialog,
          child: Text(
            '¿Olvidaste tu contraseña?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
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
            child: authProvider.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1E3A5F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Iniciando sesión...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Iniciar Sesión',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '¿No tienes una cuenta? ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Regístrate aquí',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        // Navegación automática manejada por AuthWrapper
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        String errorMessage = authProvider.error ?? 'Error de autenticación';
        
        // Primero verificar si es error de credenciales incorrectas o usuario inexistente
        if (errorMessage.toLowerCase().contains('incorrectos') ||
            errorMessage.toLowerCase().contains('invalid login credentials')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Usuario no existe o credenciales incorrectas. Por favor regístrate si aún no tienes una cuenta.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } 
        // Luego verificar si es error de email no confirmado
        else if (errorMessage.toLowerCase().contains('confirma tu email') || 
                 errorMessage.toLowerCase().contains('email not confirmed')) {
          _showEmailVerificationDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirma tu Email',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Por favor confirma tu email antes de iniciar sesión',
              style: GoogleFonts.poppins(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa tu bandeja de entrada y haz clic en el enlace de verificación',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resendVerificationEmail();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Reenviar Email',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await SupabaseService.resendVerificationEmail(
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email de verificación reenviado',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al reenviar el email: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Recuperar Contraseña',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa tu email para recibir un enlace de recuperación',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                Navigator.pop(context);
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.resetPassword(emailController.text.trim());
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Email de recuperación enviado'
                            : authProvider.error ?? 'Error enviando email',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
            ),
            child: Text(
              'Enviar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
