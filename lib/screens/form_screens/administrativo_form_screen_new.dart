import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AdministrativoFormScreen extends StatefulWidget {
  const AdministrativoFormScreen({Key? key}) : super(key: key);

  @override
  State<AdministrativoFormScreen> createState() => _AdministrativoFormScreenState();
}

class _AdministrativoFormScreenState extends State<AdministrativoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _entidadController = TextEditingController();
  final _actoAdministrativoController = TextEditingController();
  final _descripcionCasoController = TextEditingController();
  
  String _tipoCaso = 'Recurso de Reposición';
  bool _isLoading = false;

  final List<String> _tiposCasos = [
    'Recurso de Reposición',
    'Recurso de Apelación',
    'Acción de Nulidad',
    'Acción Popular',
    'Derecho de Petición',
    'Contratación Pública',
    'Licencias y Permisos',
    'Sanciones Administrativas',
    'Otros'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Formulario - Derecho Administrativo',
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
                        Icons.account_balance,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Derecho Administrativo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete la información para su consulta administrativa',
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
                
                // Información Personal
                _buildSectionTitle('Información Personal'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre Completo',
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su nombre completo';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _cedulaController,
                  label: 'Número de Cédula',
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su número de cédula';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su número de teléfono';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su correo electrónico';
                    }
                    if (!value!.contains('@')) {
                      return 'Por favor ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su dirección';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Información del Caso Administrativo
                _buildSectionTitle('Información del Caso Administrativo'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _entidadController,
                  label: 'Entidad Administrativa',
                  icon: Icons.business,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese la entidad administrativa';
                    }
                    return null;
                  },
                  hintText: 'Nombre de la entidad pública involucrada',
                ),
                
                const SizedBox(height: 16),
                
                // Tipo de caso administrativo
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
                        labelText: 'Tipo de Caso Administrativo',
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
                  controller: _actoAdministrativoController,
                  label: 'Acto Administrativo',
                  icon: Icons.description,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor describa el acto administrativo';
                    }
                    return null;
                  },
                  hintText: 'Número de resolución, decreto, etc.',
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _descripcionCasoController,
                  label: 'Descripción del Caso',
                  icon: Icons.notes,
                  maxLines: 4,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor describa su caso administrativo';
                    }
                    return null;
                  },
                  hintText: 'Describa detalladamente la situación administrativa que requiere asesoría legal',
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
        // Simular guardado en base de datos
        await Future.delayed(const Duration(seconds: 2));

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formulario enviado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla anterior
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar el formulario: $e'),
            backgroundColor: Colors.red,
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
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _entidadController.dispose();
    _actoAdministrativoController.dispose();
    _descripcionCasoController.dispose();
    super.dispose();
  }
}
