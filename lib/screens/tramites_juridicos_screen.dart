import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/legal_procedures_service.dart';

class TramitesJuridicosScreen extends StatefulWidget {
  const TramitesJuridicosScreen({super.key});

  @override
  State<TramitesJuridicosScreen> createState() => _TramitesJuridicosScreenState();
}

class _TramitesJuridicosScreenState extends State<TramitesJuridicosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Trámites Jurídicos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.school, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estos trámites solo podrán ser visualizados y aceptados por usuarios verificados como estudiantes de séptimo semestre en adelante.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección 1: Creación borradores de textos jurídicos
            _buildSectionTitle('Creación borradores de textos jurídicos'),
            const SizedBox(height: 12),
            _buildTramiteCard(
              icon: Icons.description,
              title: 'Contratos',
              description: 'Elaboración de borradores de contratos civiles y comerciales',
              onTap: () => _showDisclaimerAndNavigate('contratos'),
            ),
            _buildTramiteCard(
              icon: Icons.article,
              title: 'Tutelas y/o derechos de petición',
              description: 'Redacción de tutelas y derechos de petición',
              onTap: () => _showDisclaimerAndNavigate('tutelas'),
            ),
            _buildTramiteCard(
              icon: Icons.assignment,
              title: 'Poderes',
              description: 'Elaboración de borradores de poderes',
              onTap: () => _showDisclaimerAndNavigate('poderes'),
            ),
            
            const SizedBox(height: 24),
            
            // Sección 2: Trámites jurídicos
            _buildSectionTitle('Trámites jurídicos'),
            const SizedBox(height: 12),
            _buildTramiteCard(
              icon: Icons.send,
              title: 'Radicación de documentos',
              description: 'Radicación de documentos ante juzgados o entidades públicas',
              onTap: () => _showDisclaimerAndNavigate('radicacion'),
            ),
            _buildTramiteCard(
              icon: Icons.verified,
              title: 'Solicitud de certificados',
              description: 'Gestión de solicitud de certificados legales',
              onTap: () => _showDisclaimerAndNavigate('certificados'),
            ),
            
            const SizedBox(height: 24),
            
            // Sección 3: Conceptos
            _buildSectionTitle('Conceptos jurídicos'),
            const SizedBox(height: 12),
            _buildTramiteCard(
              icon: Icons.psychology,
              title: 'Conceptos sobre situaciones legales',
              description: 'Conceptos con respecto a situaciones que involucran derechos',
              onTap: () => _showDisclaimerAndNavigate('conceptos'),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTramiteCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDisclaimerAndNavigate(String procedureType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Recordatorio importante',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
              ),
              child: Text(
                '"Te recordamos que los estudiantes no podrán firmar poderes judiciales o actuar como apoderado en audiencias judiciales, como tampoco sustituir poder o actuar sin autorización escrita"',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber[200],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
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
            onPressed: () {
              Navigator.pop(context);
              _navigateToTramiteForm(procedureType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Entendido, continuar',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTramiteForm(String procedureType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcedureFormScreen(procedureType: procedureType),
      ),
    );
  }
}

// ========================================
// FORMULARIO DE TRÁMITE
// ========================================

class ProcedureFormScreen extends StatefulWidget {
  final String procedureType;
  
  const ProcedureFormScreen({super.key, required this.procedureType});

  @override
  State<ProcedureFormScreen> createState() => _ProcedureFormScreenState();
}

class _ProcedureFormScreenState extends State<ProcedureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _urgency = 'normal';
  bool _isLoading = false;

  Map<String, String> get _procedureInfo =>
      LegalProceduresService.procedureTypes[widget.procedureType] ?? {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          _procedureInfo['title'] ?? 'Nuevo Trámite',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del tipo de trámite
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _procedureInfo['description'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Título del trámite
              _buildLabel('Título del trámite'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: _inputDecoration('Ej: Contrato de arrendamiento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Descripción
              _buildLabel('Describe tu solicitud en detalle'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(color: Colors.white),
                maxLines: 6,
                decoration: _inputDecoration(
                  'Explica qué necesitas, incluye todos los detalles relevantes...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor describe tu solicitud';
                  }
                  if (value.length < 50) {
                    return 'La descripción debe tener al menos 50 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Urgencia
              _buildLabel('Nivel de urgencia'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  children: [
                    _buildUrgencyOption('low', 'Baja', 'Sin prisa, puede esperar', Colors.green),
                    Divider(color: Colors.grey[700], height: 1),
                    _buildUrgencyOption('normal', 'Normal', 'Tiempo estándar', Colors.blue),
                    Divider(color: Colors.grey[700], height: 1),
                    _buildUrgencyOption('high', 'Alta', 'Lo necesito pronto', Colors.orange),
                    Divider(color: Colors.grey[700], height: 1),
                    _buildUrgencyOption('urgent', 'Urgente', 'Lo antes posible', Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Publicar Solicitud',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Nota
              Text(
                'Los estudiantes verificados podrán ver tu solicitud y enviarte propuestas.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildUrgencyOption(String value, String title, String subtitle, Color color) {
    return RadioListTile<String>(
      value: value,
      groupValue: _urgency,
      onChanged: (v) => setState(() => _urgency = v!),
      activeColor: AppColors.primary,
      title: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await LegalProceduresService.createProcedure(
        procedureType: widget.procedureType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        urgency: _urgency,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Solicitud publicada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
}
