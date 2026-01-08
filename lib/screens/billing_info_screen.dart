import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';

class BillingInfoScreen extends StatefulWidget {
  @override
  _BillingInfoScreenState createState() => _BillingInfoScreenState();
}

class _BillingInfoScreenState extends State<BillingInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _nitController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillingInfo();
  }

  Future<void> _loadBillingInfo() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser != null) {
        final userProfile = await SupabaseService.getUserProfile(currentUser.id);
        if (userProfile != null) {
          setState(() {
            _companyController.text = userProfile['company_name'] ?? '';
            _nitController.text = userProfile['nit'] ?? '';
            _addressController.text = userProfile['billing_address'] ?? '';
            _cityController.text = userProfile['billing_city'] ?? '';
            _emailController.text = userProfile['billing_email'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading billing info: $e');
      setState(() {
        _isLoading = false;
      });
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
          'Información de Facturación',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBillingForm(),
                  const SizedBox(height: 24),
                  _buildTaxInfo(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildBillingForm() {
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
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Datos de Facturación',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _companyController,
            label: 'Razón Social / Empresa',
            icon: Icons.business,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nitController,
            label: 'NIT / Cédula',
            icon: Icons.badge,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email de Facturación',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es requerido';
              }
              if (!value!.contains('@')) {
                return 'Ingrese un email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Dirección Fiscal',
            icon: Icons.location_on,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'Ciudad',
            icon: Icons.location_city,
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

  Widget _buildTaxInfo() {
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
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Información Tributaria',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem('Régimen Tributario', 'Régimen Simplificado'),
          _buildInfoItem('Resolución DIAN', 'No. 000123456789'),
          _buildInfoItem('IVA Aplicable', '19%'),
          _buildInfoItem('Retención en la Fuente', '0%'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _saveBillingInfo(),
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

  Future<void> _saveBillingInfo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser != null) {
        await SupabaseService.updateUserProfile(currentUser.id, {
          'company_name': _companyController.text,
          'nit': _nitController.text,
          'billing_address': _addressController.text,
          'billing_city': _cityController.text,
          'billing_email': _emailController.text,
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Información de facturación guardada'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      print('Error saving billing info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar información'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _nitController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}