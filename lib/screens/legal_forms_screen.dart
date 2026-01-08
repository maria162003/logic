import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'form_screens/civil_form_screen.dart';
import 'form_screens/penal_form_screen.dart';
import 'form_screens/laboral_form_screen.dart';
import 'form_screens/comercial_form_screen.dart';
import 'form_screens/administrativo_form_screen.dart';
import 'form_screens/constitucional_form_screen.dart';
import 'form_screens/familia_form_screen.dart';
import 'form_screens/tributario_form_screen.dart';

class LegalFormsScreen extends StatelessWidget {
  const LegalFormsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Formularios Legales',
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona el área legal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige el tipo de formulario que necesitas para tu caso legal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildLegalAreaCard(
                  context,
                  'Penal',
                  Icons.security,
                  'Delitos, procesos penales, defensa',
                  const PenalFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Laboral',
                  Icons.work,
                  'Contratos de trabajo, despidos, salarios',
                  const LaboralFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Comercial',
                  Icons.business,
                  'Empresas, sociedades, comercio',
                  const ComercialFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Administrativo',
                  Icons.account_balance,
                  'Actos administrativos, contratación pública',
                  const AdministrativoFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Constitucional',
                  Icons.balance,
                  'Derechos fundamentales, tutelas',
                  const ConstitucionalFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Familia',
                  Icons.family_restroom,
                  'Divorcios, alimentos, custodia',
                  const FamiliaFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Civil',
                  Icons.gavel,
                  'Contratos, propiedad, responsabilidad',
                  const CivilFormScreen(),
                ),
                _buildLegalAreaCard(
                  context,
                  'Tributario',
                  Icons.account_balance_wallet,
                  'Impuestos, tributación, DIAN',
                  const TributarioFormScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalAreaCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    Widget screen,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          try {
            print('🔍 NAVEGACION: Intentando navegar a $title');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
            print('✅ NAVEGACION: Navegación exitosa a $title');
          } catch (e) {
            print('❌ NAVEGACION: Error navegando a $title: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al abrir formulario $title: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
