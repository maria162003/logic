import 'package:flutter/material.dart';
import '../models/procedure.dart';

class LegalProceduresScreen extends StatefulWidget {
  const LegalProceduresScreen({super.key});

  @override
  State<LegalProceduresScreen> createState() => _LegalProceduresScreenState();
}

class _LegalProceduresScreenState extends State<LegalProceduresScreen> {
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    // Mostrar recordatorio al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTermsDialog();
    });
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Recordatorio importante',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Te recordamos que los estudiantes no podrán:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Firmar poderes judiciales',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            Text(
              '• Actuar como apoderado en audiencias judiciales',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            Text(
              '• Sustituir poder',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            Text(
              '• Actuar sin autorización escrita',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              'Estos trámites sólo podrán ser visualizados y aceptados por usuarios verificados como estudiantes de séptimo semestre en adelante.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _acceptedTerms = true;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B6B6B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B6B6B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trámites Jurídicos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _acceptedTerms ? _buildProcedureOptions() : const SizedBox(),
    );
  }

  Widget _buildProcedureOptions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Descripción
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.blue.shade700, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Conecta con estudiantes de derecho para trámites jurídicos económicos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Creación de borradores
        _buildProcedureCard(
          title: 'Creación de borradores de textos jurídicos',
          description: 'Contratos, tutelas, derechos de petición, poderes',
          icon: Icons.edit_document,
          color: Colors.purple,
          subtypes: [
            'Contratos',
            'Tutelas y/o derechos de petición',
            'Poderes',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Trámites jurídicos
        _buildProcedureCard(
          title: 'Trámites jurídicos',
          description: 'Radicación de documentos, solicitud de certificados',
          icon: Icons.assignment,
          color: Colors.orange,
          subtypes: [
            'Radicación de documentos ante juzgados o entidades públicas',
            'Solicitud de certificados',
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Conceptos legales
        _buildProcedureCard(
          title: 'Conceptos legales',
          description: 'Asesoría sobre situaciones que involucran derechos',
          icon: Icons.lightbulb_outline,
          color: Colors.green,
          subtypes: [
            'Análisis de situaciones jurídicas',
            'Conceptos sobre derechos',
            'Orientación legal básica',
          ],
        ),
      ],
    );
  }

  Widget _buildProcedureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> subtypes,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Subtypes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Opciones disponibles:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...subtypes.map((subtype) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subtype,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                
                // Botón de solicitar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a formulario de solicitud
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Solicitar trámite',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
}
