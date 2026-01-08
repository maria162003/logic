import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser != null) {
        final userProfile = await SupabaseService.getUserProfile(currentUser.id);
        if (userProfile != null) {
          setState(() {
            // Cargar métodos de pago desde JSON o crear lista vacía
            final paymentMethodsJson = userProfile['payment_methods'] as List<dynamic>?;
            _paymentMethods = paymentMethodsJson?.cast<Map<String, dynamic>>() ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading payment methods: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePaymentMethods() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser != null) {
        await SupabaseService.updateUserProfile(currentUser.id, {
          'payment_methods': _paymentMethods,
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Métodos de pago actualizados'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      print('Error saving payment methods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar métodos de pago'),
          backgroundColor: Colors.red,
        ),
      );
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
          'Métodos de Pago',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddPaymentMethodButton(),
                const SizedBox(height: 24),
                _buildPaymentMethodsList(),
                const SizedBox(height: 24),
                _buildSecurityInfo(),
              ],
            ),
          ),
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_card,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Agregar Método de Pago',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega una tarjeta, cuenta PSE o método de pago',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddPaymentDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Agregar Método',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
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
            'Métodos Guardados',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodItem(
            icon: Icons.credit_card,
            title: 'Tarjeta de Crédito',
            subtitle: '**** **** **** 1234',
            isDefault: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            icon: Icons.account_balance,
            title: 'PSE',
            subtitle: 'Banco de Colombia',
            isDefault: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: isDefault 
            ? Border.all(color: AppColors.primary.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PREDETERMINADO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
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
              Icon(Icons.security, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Seguridad de Pagos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecurityItem('Encriptación SSL 256-bit'),
          _buildSecurityItem('Cumplimiento PCI DSS'),
          _buildSecurityItem('Protección contra fraude'),
          _buildSecurityItem('Monitoreo 24/7'),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final cardNumberController = TextEditingController();
        final cardHolderController = TextEditingController();
        final expiryController = TextEditingController();
        final cvvController = TextEditingController();
        
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Agregar Método de Pago',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cardNumberController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Número de tarjeta',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: cardHolderController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Titular de la tarjeta',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'MM/AA',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (cardNumberController.text.isNotEmpty &&
                    cardHolderController.text.isNotEmpty &&
                    expiryController.text.isNotEmpty &&
                    cvvController.text.isNotEmpty) {
                  
                  setState(() {
                    _paymentMethods.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'type': 'card',
                      'last_four': cardNumberController.text.substring(
                        cardNumberController.text.length - 4
                      ),
                      'card_holder': cardHolderController.text,
                      'expiry': expiryController.text,
                      'is_default': _paymentMethods.isEmpty,
                    });
                  });
                  
                  _savePaymentMethods();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}