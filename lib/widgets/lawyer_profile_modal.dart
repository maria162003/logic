import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerProfileModal extends StatelessWidget {
  final Map<String, dynamic> lawyer;

  const LawyerProfileModal({
    super.key,
    required this.lawyer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFBB8B30),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: lawyer['profileImage'] != null && 
                                   lawyer['profileImage'].isNotEmpty
                        ? NetworkImage(lawyer['profileImage'])
                        : null,
                    child: lawyer['profileImage'] == null || 
                           lawyer['profileImage'].isEmpty
                        ? Text(
                            lawyer['name'][0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFBB8B30),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lawyer['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          lawyer['specialty'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    _buildInfoSection(
                      'Información Básica',
                      [
                        _buildInfoRow(Icons.location_on, 'Ubicación', lawyer['location']),
                        _buildInfoRow(Icons.work, 'Experiencia', '${lawyer['experience']} años'),
                        _buildInfoRow(Icons.school, 'Universidad', lawyer['university'] ?? 'No especificada'),
                        _buildInfoRow(Icons.attach_money, 'Rango de precios', lawyer['priceRange']),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Rating
                    _buildInfoSection(
                      'Calificación',
                      [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${lawyer['rating'].toStringAsFixed(1)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${lawyer['reviewCount']} reseñas)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    if (lawyer['description'] != null && lawyer['description'].isNotEmpty)
                      _buildInfoSection(
                        'Descripción',
                        [
                          Text(
                            lawyer['description'],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Languages
                    if (lawyer['languages'] != null && lawyer['languages'].isNotEmpty)
                      _buildInfoSection(
                        'Idiomas',
                        [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (lawyer['languages'] as List<dynamic>)
                                .map<Widget>((language) => Chip(
                                      label: Text(
                                        language.toString(),
                                        style: GoogleFonts.inter(fontSize: 12),
                                      ),
                                      backgroundColor: const Color(0xFFBB8B30).withValues(alpha: 0.1),
                                      side: const BorderSide(color: Color(0xFFBB8B30)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Case Types
                    if (lawyer['caseTypes'] != null && lawyer['caseTypes'].isNotEmpty)
                      _buildInfoSection(
                        'Tipos de Casos',
                        [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (lawyer['caseTypes'] as List<dynamic>)
                                .map<Widget>((caseType) => Chip(
                                      label: Text(
                                        caseType.toString(),
                                        style: GoogleFonts.inter(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                      side: const BorderSide(color: Colors.blue),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Achievements
                    if (lawyer['achievements'] != null && lawyer['achievements'].isNotEmpty)
                      _buildInfoSection(
                        'Logros y Certificaciones',
                        (lawyer['achievements'] as List<dynamic>)
                            .map<Widget>((achievement) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star_border,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          achievement.toString(),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBB8B30)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cerrar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFBB8B30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Aquí puedes agregar la lógica para contactar al abogado
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contactando a ${lawyer['name']}...'),
                            backgroundColor: const Color(0xFFBB8B30),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBB8B30),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Contactar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
