import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_config_provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _idController = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    try {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      
      if (userId != null) {
        print('🔍 PersonalInfo: Cargando información para usuario $userId');
        
        // Cargar perfil del usuario desde Supabase
        final userProfile = await SupabaseService.getUserProfile(userId);
        
        if (userProfile != null) {
          print('📋 PersonalInfo: Datos del perfil recibidos: $userProfile');
          
          setState(() {
            _nameController.text = userProfile['full_name'] ?? '';
            _phoneController.text = userProfile['phone'] ?? '';
            _addressController.text = userProfile['location'] ?? '';  
            _idController.text = userProfile['document_number'] ?? '';
          });
          
          print('✅ PersonalInfo: Campos actualizados:');
          print('   - Nombre: ${_nameController.text}');
          print('   - Teléfono: ${_phoneController.text}');
          print('   - Dirección: ${_addressController.text}');
          print('   - Documento: ${_idController.text}');
          
          // Si algunos campos están vacíos, mostrar mensaje informativo
          List<String> camposVacios = [];
          if (_phoneController.text.isEmpty) camposVacios.add('Teléfono');
          if (_addressController.text.isEmpty) camposVacios.add('Dirección');
          if (_idController.text.isEmpty) camposVacios.add('Documento');
          
          if (camposVacios.isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Puedes completar: ${camposVacios.join(', ')}'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          print('⚠️ PersonalInfo: No se encontró perfil, usando datos del usuario autenticado');
          // Si no hay perfil, usar datos del usuario autenticado
          final user = authProvider.user;
          if (user != null) {
            setState(() {
              _nameController.text = user.userMetadata?['full_name'] ?? '';
              _phoneController.text = user.userMetadata?['phone'] ?? '';
              _addressController.text = user.userMetadata?['address'] ?? '';
              _idController.text = user.userMetadata?['document_number'] ?? '';
            });
          }
        }
      } else {
        print('❌ PersonalInfo: No hay usuario autenticado');
      }
    } catch (e) {
      print('❌ PersonalInfo: Error cargando información personal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la información: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Información Personal',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading 
        ? Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : Consumer2<UserConfigProvider, AuthProvider>(
            builder: (context, configProvider, authProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(authProvider, configProvider),
                      const SizedBox(height: 32),
                      _buildFormSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(configProvider),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, UserConfigProvider configProvider) {
    return Container(
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
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              ),
            ),
            child: Icon(
              Icons.person,
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
                  authProvider.user?.email ?? 'Usuario',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  configProvider.membershipDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos Personales',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'Nombre Completo',
            icon: Icons.person_outline,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'El teléfono es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _idController,
            label: 'Número de Identificación',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Dirección',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSaveButton(UserConfigProvider configProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _savePersonalInfo(configProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Guardar Información',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _savePersonalInfo(UserConfigProvider configProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _isLoading = true);
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.id;
        
        if (userId != null) {
          // Actualizar perfil en Supabase
          await SupabaseService.updateUserProfile(userId, {
            'full_name': _nameController.text,
            'phone': _phoneController.text,
            'location': _addressController.text,
            'document_number': _idController.text,
          });
          
          // También actualizar en el provider para compatibilidad
          await configProvider.setPersonalInfo(
            fullName: _nameController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            idNumber: _idController.text,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Información guardada exitosamente'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );

            Navigator.pop(context);
          }
        }
      } catch (e) {
        print('Error guardando información personal: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _idController.dispose();
    super.dispose();
  }
}