import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

class LawyerProfileConfigScreen extends StatefulWidget {
  const LawyerProfileConfigScreen({super.key});

  @override
  State<LawyerProfileConfigScreen> createState() => _LawyerProfileConfigScreenState();
}

class _LawyerProfileConfigScreenState extends State<LawyerProfileConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _fullNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  
  // Estados
  List<String> _selectedSpecializations = [];
  List<String> _certifications = [];
  bool _isVerified = false;
  bool _isAvailable = true;
  bool _isLoading = false;

  // Especialidades disponibles
  final List<String> _availableSpecializations = [
    'Civil',
    'Penal',
    'Laboral',
    'Comercial',
    'Familiar',
    'Tributario',
    'Administrativo',
    'Constitucional',
    'Ambiental',
    'Inmobiliario',
    'Propiedad Intelectual',
    'Corporativo',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Cargar datos básicos del usuario
      _fullNameController.text = authProvider.userName ?? '';
      _phoneController.text = authProvider.userPhone ?? '';
      _locationController.text = authProvider.userLocation ?? '';
      
      // Cargar datos específicos del abogado desde Supabase
      if (authProvider.userId != null) {
        final lawyerProfile = await SupabaseService.getLawyerProfile(authProvider.userId!);
        
        if (lawyerProfile != null) {
          setState(() {
            _licenseNumberController.text = lawyerProfile['license_number'] ?? '';
            _experienceController.text = lawyerProfile['experience_years']?.toString() ?? '';
            _educationController.text = lawyerProfile['education'] ?? '';
            _bioController.text = lawyerProfile['bio'] ?? '';
            _hourlyRateController.text = lawyerProfile['hourly_rate']?.toString() ?? '';
            _selectedSpecializations = List<String>.from(lawyerProfile['specializations'] ?? []);
            _certifications = List<String>.from(lawyerProfile['certifications'] ?? []);
            _isVerified = lawyerProfile['is_verified'] ?? false;
            _isAvailable = lawyerProfile['is_available'] ?? true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos del perfil: $e'),
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Perfil Profesional',
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
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Guardar',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información Personal
              _buildSectionHeader('Información Personal', Icons.person),
              _buildTextField(
                controller: _fullNameController,
                label: 'Nombre Completo',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Ubicación',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Biografía Profesional',
                icon: Icons.description,
                maxLines: 4,
                hintText: 'Describe tu experiencia y enfoque profesional...',
              ),

              const SizedBox(height: 30),

              // Información Profesional
              _buildSectionHeader('Información Profesional', Icons.work),
              
              // Solo mostrar número de licencia para abogados, no para estudiantes
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final isStudent = authProvider.userType == 'student';
                  
                  if (!isStudent) {
                    return Column(
                      children: [
                        _buildTextField(
                          controller: _licenseNumberController,
                          label: 'Número de Licencia',
                          icon: Icons.badge,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El número de licencia es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  } else {
                    // Para estudiantes, mostrar información académica
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school,
                                color: Colors.blue[300],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Perfil de Estudiante',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Como estudiante de derecho, tienes acceso completo a la plataforma excepto por la emisión de certificaciones profesionales.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                },
              ),
              _buildTextField(
                controller: _experienceController,
                label: 'Años de Experiencia',
                icon: Icons.timeline,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Los años de experiencia son requeridos';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _educationController,
                label: 'Educación',
                icon: Icons.school,
                maxLines: 2,
                hintText: 'Universidad, títulos, especializaciones...',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _hourlyRateController,
                label: 'Tarifa por Hora (COP)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                hintText: '150000',
              ),

              const SizedBox(height: 30),

              // Especialidades
              _buildSectionHeader('Especialidades Legales', Icons.gavel),
              _buildSpecializationsSection(),

              const SizedBox(height: 30),

              // Certificaciones
              _buildSectionHeader('Certificaciones', Icons.verified),
              _buildCertificationsSection(),

              const SizedBox(height: 30),

              // Estados
              _buildSectionHeader('Estado Profesional', Icons.toggle_on),
              _buildToggleSection(),

              const SizedBox(height: 40),
            ],
          ),
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _buildSpecializationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona tus áreas de especialización:',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecializations.map((spec) {
              final isSelected = _selectedSpecializations.contains(spec);
              return FilterChip(
                label: Text(
                  spec,
                  style: GoogleFonts.poppins(
                    color: isSelected ? AppColors.onPrimary : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecializations.add(spec);
                    } else {
                      _selectedSpecializations.remove(spec);
                    }
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.onPrimary,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.white30,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Certificaciones y Títulos:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: _addCertification,
                icon: Icon(Icons.add, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_certifications.isEmpty)
            Text(
              'No hay certificaciones agregadas',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            )
          else
            ...(_certifications.asMap().entries.map((entry) {
              final index = entry.key;
              final cert = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cert,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeCertification(index),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList()),
        ],
      ),
    );
  }

  Widget _buildToggleSection() {
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
            title: Text(
              'Verificado',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            subtitle: Text(
              'Cuenta verificada por Logic Lex',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            value: _isVerified,
            onChanged: null, // Solo administradores pueden cambiar esto
            activeColor: AppColors.primary,
            tileColor: Colors.transparent,
          ),
          const Divider(color: Colors.white30),
          SwitchListTile(
            title: Text(
              'Disponible',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            subtitle: Text(
              'Aceptando nuevos casos',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeColor: AppColors.primary,
            tileColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _addCertification() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Agregar Certificación',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nombre de la certificación',
              hintStyle: GoogleFonts.poppins(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _certifications.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Agregar', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final isStudent = authProvider.userType == 'student';

      // Guardar datos en Supabase
      await SupabaseService.updateLawyerProfile(
        lawyerId: authProvider.userId!,
        licenseNumber: isStudent ? null : _licenseNumberController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()),
        education: _educationController.text.trim(),
        bio: _bioController.text.trim(),
        hourlyRate: double.tryParse(_hourlyRateController.text.trim()),
        specializations: _selectedSpecializations,
        certifications: _certifications,
        isAvailable: _isAvailable,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Perfil actualizado exitosamente',
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
              'Error al actualizar perfil: $e',
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
}