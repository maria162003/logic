import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider_supabase.dart';
import '../utils/app_colors.dart';
import 'registration_success_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Campos básicos
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Campos de identificación
  final _documentNumberController = TextEditingController();
  String _documentType = 'Cédula de Ciudadanía';
  
  // Campos específicos del abogado
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Campos específicos del estudiante
  final _universityController = TextEditingController();
  final _semesterController = TextEditingController();
  final _studentDocumentController = TextEditingController();
  
  String _userType = 'client';
  String? _selectedLocation;
  final List<String> _selectedSpecializations = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // Tipos de documento válidos para adultos (no tarjeta de identidad ni registro civil)
  static const List<String> documentTypes = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
    'Pasaporte',
    'Permiso por Protección Temporal (PPT)',
    'Permiso Especial de Permanencia (PEP)',
  ];

  // Opciones disponibles - Colombia
  static const List<String> locations = [
    'Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena', 'Cúcuta', 
    'Bucaramanga', 'Pereira', 'Santa Marta', 'Ibagué', 'Pasto',
    'Manizales', 'Neiva', 'Villavicencio', 'Armenia', 'Valledupar',
    'Montería', 'Sincelejo', 'Popayán', 'Tunja', 'Florencia'
  ];

  static const List<String> specializations = [
    'Civil', 'Penal', 'Laboral', 'Familiar', 'Comercial', 'Administrativo',
    'Constitucional', 'Tributario', 'Ambiental', 'Tecnológico', 'Inmobiliario',
    'Propiedad Intelectual', 'Migración', 'Salud', 'Educativo'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _documentNumberController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _bioController.dispose();
    _universityController.dispose();
    _semesterController.dispose();
    _studentDocumentController.dispose();
    _pageController.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAppBar(),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildUserTypeStep(),
                      _buildBasicInfoStep(),
                      if (_userType == 'lawyer') _buildLawyerInfoStep(),
                      if (_userType == 'student') _buildStudentInfoStep(),
                      _buildConfirmationStep(),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Crear Cuenta',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Para balancear el botón de atrás
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalSteps = (_userType == 'lawyer' || _userType == 'student') ? 4 : 3;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            '¿Qué tipo de usuario eres?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selecciona el tipo de cuenta que mejor se adapte a ti',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 40),
          
          // Opción Cliente
          _buildUserTypeCard(
            type: 'client',
            title: 'Soy Cliente',
            subtitle: 'Busco servicios legales y asesoramiento',
            icon: Icons.person,
            description: 'Conecta con abogados especializados, publica casos en el marketplace y obtén asesoría legal profesional.',
          ),
          
          const SizedBox(height: 20),
          
          // Opción Abogado
          _buildUserTypeCard(
            type: 'lawyer',
            title: 'Soy Abogado',
            subtitle: 'Ofrezco servicios legales profesionales',
            icon: Icons.balance,
            description: 'Encuentra clientes, participa en el marketplace legal y haz crecer tu práctica profesional.',
          ),
          
          const SizedBox(height: 20),
          
          // Opción Estudiante de Derecho
          _buildUserTypeCard(
            type: 'student',
            title: 'Soy Estudiante de Derecho',
            subtitle: 'Estudio derecho y busco oportunidades',
            icon: Icons.school,
            description: 'Accede a casos reales, aprende de abogados experimentados y construye tu portafolio legal.',
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _userType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _userType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 30,
                color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Información Básica',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Completa tu información personal',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          
          // Nombre completo
          _buildTextField(
            controller: _fullNameController,
            label: 'Nombre Completo',
            hint: 'Tu nombre completo',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'tu.email@ejemplo.com',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El email es requerido';
              }
              if (!value.contains('@')) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Teléfono
          _buildTextField(
            controller: _phoneController,
            label: 'Teléfono (Opcional)',
            hint: '+57 320 782 5678',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 20),
          
          // Tipo de documento
          _buildDocumentTypeDropdown(),
          
          const SizedBox(height: 20),
          
          // Número de documento
          _buildTextField(
            controller: _documentNumberController,
            label: 'Número de Documento',
            hint: 'Ingresa tu número de documento',
            icon: Icons.badge,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El número de documento es requerido';
              }
              if (value.length < 6) {
                return 'Número de documento muy corto';
              }
              // Validación específica por tipo de documento
              if (_documentType == 'Cédula de Ciudadanía' && value.length < 8) {
                return 'La cédula debe tener al menos 8 dígitos';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Ubicación
          _buildLocationDropdown(),
          
          const SizedBox(height: 20),
          
          // Contraseña
          _buildPasswordField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Mínimo 6 caracteres',
            obscure: _obscurePassword,
            onToggle: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 6) {
                return 'Mínimo 6 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Confirmar contraseña
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmar Contraseña',
            hint: 'Repite tu contraseña',
            obscure: _obscureConfirmPassword,
            onToggle: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Información Profesional',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Completa tu perfil profesional como abogado',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          
          // Número de cédula
          _buildTextField(
            controller: _licenseController,
            label: 'Número de Cédula Profesional',
            hint: '12345678',
            icon: Icons.verified_user,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La cédula profesional es requerida';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Años de experiencia
          _buildTextField(
            controller: _experienceController,
            label: 'Años de Experiencia',
            hint: '5',
            icon: Icons.work,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Los años de experiencia son requeridos';
              }
              final years = int.tryParse(value);
              if (years == null || years < 0) {
                return 'Ingresa un número válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Especializaciones
          _buildSpecializationsField(),
          
          const SizedBox(height: 20),
          
          // Educación
          _buildTextField(
            controller: _educationController,
            label: 'Educación (Opcional)',
            hint: 'Universidad, maestrías, cursos...',
            icon: Icons.school,
            maxLines: 3,
          ),
          
          const SizedBox(height: 20),
          
          // Biografía
          _buildTextField(
            controller: _bioController,
            label: 'Biografía Profesional (Opcional)',
            hint: 'Describe tu experiencia y enfoque profesional...',
            icon: Icons.description,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Información Académica',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Completa tu perfil como estudiante de derecho',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          
          // Universidad
          _buildTextField(
            controller: _universityController,
            label: 'Universidad',
            hint: 'Ej: Universidad Nacional de Colombia',
            icon: Icons.school,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La universidad es requerida';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Semestre actual
          _buildTextField(
            controller: _semesterController,
            label: 'Semestre Actual',
            hint: 'Ej: 5',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El semestre actual es requerido';
              }
              final semester = int.tryParse(value);
              if (semester == null || semester < 1 || semester > 12) {
                return 'Ingresa un semestre válido (1-12)';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Archivo de constancia
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Constancia Universitaria o Carnet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Sube tu constancia de estudios o carnet universitario (PDF o imagen)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar selección de archivo
                      _showFileUploadDialog();
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(
                      _studentDocumentController.text.isEmpty 
                          ? 'Seleccionar archivo' 
                          : 'Archivo seleccionado',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Información adicional
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[300],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Beneficios para estudiantes',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Acceso a casos reales para aprendizaje\n'
                  '• Mentoría de abogados experimentados\n'
                  '• Oportunidades de práctica profesional\n'
                  '• Red de contactos en el sector legal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Confirmar Registro',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Revisa tu información antes de crear la cuenta',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          
          // Resumen de información
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem('Tipo de usuario', 
                  _userType == 'client' ? 'Cliente' : 
                  _userType == 'lawyer' ? 'Abogado' : 'Estudiante de Derecho'),
                _buildSummaryItem('Nombre', _fullNameController.text),
                _buildSummaryItem('Email', _emailController.text),
                _buildSummaryItem('Tipo de documento', _documentType),
                _buildSummaryItem('Número de documento', _documentNumberController.text),
                if (_phoneController.text.isNotEmpty)
                  _buildSummaryItem('Teléfono', _phoneController.text),
                if (_selectedLocation != null)
                  _buildSummaryItem('Ubicación', _selectedLocation!),
                if (_userType == 'lawyer') ...[
                  _buildSummaryItem('Cédula', _licenseController.text),
                  _buildSummaryItem('Experiencia', '${_experienceController.text} años'),
                  if (_selectedSpecializations.isNotEmpty)
                    _buildSummaryItem('Especializaciones', _selectedSpecializations.join(', ')),
                ],
                if (_userType == 'student') ...[
                  _buildSummaryItem('Universidad', _universityController.text),
                  _buildSummaryItem('Semestre', _semesterController.text),
                  if (_studentDocumentController.text.isNotEmpty)
                    _buildSummaryItem('Documento', 'Archivo subido'),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Términos y condiciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _acceptTerms ? AppColors.primary : Colors.red.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  checkColor: const Color(0xFF1E3A5F),
                  side: BorderSide(
                    color: _acceptTerms ? AppColors.primary : Colors.red.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        text: 'Acepto los ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        children: [
                          TextSpan(
                            text: 'términos de servicio',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' y la ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          TextSpan(
                            text: 'política de privacidad',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' de Logic Lex',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (!_acceptTerms)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[300],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Debes aceptar los términos y condiciones para continuar',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red[300],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: onToggle,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación (Opcional)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Selecciona tu ubicación',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.location_on,
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
          dropdownColor: const Color(0xFF1E3A5F),
          items: locations.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(
                location,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLocation = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Documento',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _documentType,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Selecciona tu tipo de documento',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              Icons.badge,
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
          dropdownColor: const Color(0xFF1E3A5F),
          items: documentTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _documentType = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El tipo de documento es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpecializationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especializaciones',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona tus áreas de especialización',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specializations.map((spec) {
              final isSelected = _selectedSpecializations.contains(spec);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSpecializations.remove(spec);
                    } else {
                      _selectedSpecializations.add(spec);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    spec,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final totalSteps = (_userType == 'lawyer' || _userType == 'student') ? 4 : 3;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Anterior',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final canProceed = authProvider.isLoading ? false : 
                    (_currentStep == totalSteps - 1 ? _validateCurrentStep() : true);
                
                return ElevatedButton(
                  onPressed: canProceed 
                      ? (_currentStep == totalSteps - 1 ? _handleRegister : _goToNextStep)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canProceed ? Colors.white : Colors.grey[400],
                    foregroundColor: canProceed ? const Color(0xFF1E3A5F) : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                              'Creando cuenta...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _currentStep == totalSteps - 1 ? 'Crear Cuenta' : 'Siguiente',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextStep() {
    if (!_validateCurrentStep()) return;
    
    final totalSteps = (_userType == 'lawyer' || _userType == 'student') ? 4 : 3;
    if (_currentStep < totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return true; // User type is always valid
      case 1:
        return _formKey.currentState?.validate() ?? false;
      case 2:
        if (_userType == 'lawyer') {
          return _licenseController.text.isNotEmpty &&
                 _experienceController.text.isNotEmpty &&
                 _selectedSpecializations.isNotEmpty;
        } else if (_userType == 'student') {
          return _universityController.text.isNotEmpty &&
                 _semesterController.text.isNotEmpty;
        }
        return true;
      case 3:
        return _acceptTerms;
      default:
        return true;
    }
  }

  Future<void> _handleRegister() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Debes aceptar los términos y condiciones para crear tu cuenta',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_userType == 'client') {
      success = await authProvider.registerClient(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        documentType: _documentType,
        documentNumber: _documentNumberController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _selectedLocation,
      );
    } else if (_userType == 'lawyer') {
      success = await authProvider.registerLawyer(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        documentType: _documentType,
        documentNumber: _documentNumberController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        specialization: _selectedSpecializations,
        experienceYears: int.parse(_experienceController.text),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _selectedLocation,
        education: _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      );
    } else { // student
      success = await authProvider.registerStudent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        documentType: _documentType,
        documentNumber: _documentNumberController.text.trim(),
        university: _universityController.text.trim(),
        semester: int.parse(_semesterController.text),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _selectedLocation,
        documentPath: _studentDocumentController.text.trim().isEmpty ? null : _studentDocumentController.text.trim(),
      );
    }

    if (mounted) {
      if (success) {
        // Ir a pantalla de éxito en lugar de home directamente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistrationSuccessScreen(),
          ),
        );
      } else {
        // Mostrar error con mensajes específicos para el usuario
        String errorMessage = authProvider.error ?? 'Error en el registro';
        String userFriendlyMessage = _getUserFriendlyErrorMessage(errorMessage);
        
        // Si el error es de perfil, aún así considerarlo éxito
        if (errorMessage.contains('profile') || errorMessage.contains('policy') || errorMessage.contains('401')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationSuccessScreen(),
            ),
          );
        } else {
          // Mostrar alert dialog más visible para errores de autenticación
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E3A5F),
                title: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Error en el Registro',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  userFriendlyMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD4AF37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  void _showFileUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E3A5F),
          title: Text(
            'Subir Documento',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Por ahora, ingresa el nombre del archivo que planeas subir. La funcionalidad de subida se implementará próximamente.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _studentDocumentController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ej: constancia_estudiante.pdf',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {}); // Actualizar el estado para mostrar el archivo seleccionado
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Guardar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getUserFriendlyErrorMessage(String originalError) {
    // Convertir errores técnicos en mensajes amigables para el usuario
    if (originalError.contains('User already registered') || 
        originalError.contains('already registered') ||
        originalError.contains('already exists')) {
      return 'Este correo electrónico ya está registrado. Por favor, usa un correo diferente o inicia sesión si ya tienes una cuenta.';
    }
    
    if (originalError.contains('Invalid email') ||
        originalError.contains('email format')) {
      return 'El formato del correo electrónico no es válido. Por favor, verifica que esté escrito correctamente.';
    }
    
    if (originalError.contains('Password') ||
        originalError.contains('password')) {
      return 'La contraseña no cumple con los requisitos. Debe tener al menos 6 caracteres.';
    }
    
    if (originalError.contains('422') ||
        originalError.contains('Unprocessable')) {
      return 'Los datos ingresados no son válidos. Por favor, verifica la información y vuelve a intentar.';
    }
    
    if (originalError.contains('network') ||
        originalError.contains('connection') ||
        originalError.contains('timeout')) {
      return 'Problema de conexión. Por favor, verifica tu conexión a internet e intenta nuevamente.';
    }
    
    // Mensaje genérico para errores desconocidos
    return 'Ocurrió un error durante el registro. Por favor, verifica tus datos e intenta nuevamente. Si el problema persiste, contacta al soporte.';
  }
}
