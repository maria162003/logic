import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider_supabase.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/date_picker_field.dart';

class LaboralFormScreen extends StatefulWidget {
  const LaboralFormScreen({Key? key}) : super(key: key);

  @override
  State<LaboralFormScreen> createState() => _LaboralFormScreenState();
}

class _LaboralFormScreenState extends State<LaboralFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para los campos específicos del caso
  final _tituloController = TextEditingController();
  final _empresaController = TextEditingController();
  final _cargoController = TextEditingController();
  final _fechaIngresoController = TextEditingController();
  final _fechaRetiroController = TextEditingController();
  final _descripcionCasoController = TextEditingController();
  final _documentosController = TextEditingController();
  
  String _tipoCaso = 'Terminación de Contrato';
  String _tipoContrato = 'Indefinido';
  bool _isLoading = false;

  final List<String> _tiposCasos = [
    'Terminación de Contrato',
    'Despido sin Justa Causa',
    'Acoso Laboral',
    'Reclamación Salarial',
    'Licencias de Maternidad/Paternidad',
    'Accidente de Trabajo',
    'Enfermedad Profesional',
    'Estabilidad Laboral Reforzada',
    'Fuero Sindical',
    'Otros'
  ];

  final List<String> _tiposContrato = [
    'Indefinido',
    'Fijo',
    'Por Obra o Labor',
    'Prestación de Servicios',
    'Aprendizaje',
    'Temporal'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Formulario - Derecho Laboral',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del formulario
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.work,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Derecho Laboral',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete la información para su consulta laboral',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Título del caso
                _buildTextField(
                  controller: _tituloController,
                  label: 'Título del Caso',
                  icon: Icons.title,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese un título para el caso';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Información Laboral
                _buildSectionTitle('Información Laboral'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _empresaController,
                  label: 'Nombre de la Empresa',
                  icon: Icons.business,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese el nombre de la empresa';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _cargoController,
                  label: 'Cargo Desempeñado',
                  icon: Icons.work_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese el cargo desempeñado';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Tipo de contrato
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: _tipoContrato,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Contrato',
                        labelStyle: TextStyle(color: AppColors.primary),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.description, color: AppColors.primary),
                      ),
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white),
                      items: _tiposContrato.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoContrato = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                DatePickerField(
                  controller: _fechaIngresoController,
                  label: 'Fecha de Ingreso',
                  icon: Icons.calendar_today,
                  hintText: 'Seleccionar fecha de ingreso',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese la fecha de ingreso';
                    }
                    return null;
                  },
                  lastDate: DateTime.now(),
                ),
                
                const SizedBox(height: 16),
                
                DatePickerField(
                  controller: _fechaRetiroController,
                  label: 'Fecha de Retiro',
                  icon: Icons.event_busy,
                  hintText: 'Seleccionar fecha de retiro (Si aplica)',
                  lastDate: DateTime.now(),
                ),
                
                const SizedBox(height: 32),
                
                // Información del Caso Laboral
                _buildSectionTitle('Información del Caso Laboral'),
                const SizedBox(height: 16),
                
                // Tipo de caso
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: _tipoCaso,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Caso Laboral',
                        labelStyle: TextStyle(color: AppColors.primary),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.category, color: AppColors.primary),
                      ),
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white),
                      items: _tiposCasos.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoCaso = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _descripcionCasoController,
                  label: 'Descripción del Caso',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor describa su caso laboral';
                    }
                    return null;
                  },
                  hintText: 'Describa detalladamente la situación laboral que requiere asesoría legal',
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _documentosController,
                  label: 'Documentos Disponibles',
                  icon: Icons.attach_file,
                  maxLines: 3,
                  hintText: 'Describa los documentos que tiene relacionados con el caso',
                ),
                
                const SizedBox(height: 32),
                
                // Botón de envío
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Enviar Formulario',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: AppColors.primary),
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[900],
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
        
        final user = authProvider.user;
        if (user == null) {
          throw Exception('Usuario no autenticado');
        }

        // Crear el caso en el marketplace
        final success = await marketplaceProvider.createCase(
          title: _tituloController.text,
          description: _descripcionCasoController.text,
          category: 'Laboral', // Categoría general en lugar del tipo específico
          documents: _documentosController.text.isNotEmpty 
              ? [_documentosController.text] 
              : null,
        );

        if (success) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Caso enviado exitosamente al marketplace'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          // Volver a la pantalla anterior
          Navigator.pop(context);
        } else {
          throw Exception('No se pudo crear el caso');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar el caso: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _empresaController.dispose();
    _cargoController.dispose();
    _fechaIngresoController.dispose();
    _fechaRetiroController.dispose();
    _descripcionCasoController.dispose();
    _documentosController.dispose();
    super.dispose();
  }
}
