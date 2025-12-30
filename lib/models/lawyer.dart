import 'case.dart';

enum LawyerType {
  professional,  // Abogado profesional
  student        // Estudiante de derecho
}

class Lawyer {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String location;
  final LawyerType type;
  final double rating;
  final List<LegalArea> specialties;
  final int? semester; // Para estudiantes
  final bool isVerified;

  Lawyer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.location,
    required this.type,
    this.rating = 0.0,
    this.specialties = const [],
    this.semester,
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName';

  String get typeName {
    switch (type) {
      case LawyerType.professional:
        return 'Abogado profesional';
      case LawyerType.student:
        return 'Estudiante derecho';
    }
  }

  String get specialtiesText {
    if (specialties.isEmpty) return '';
    
    List<String> names = specialties.map((area) {
      switch (area) {
        case LegalArea.familiar:
          return 'Familiar';
        case LegalArea.laboral:
          return 'Laboral';
        case LegalArea.penal:
          return 'Penal';
        case LegalArea.civil:
          return 'Civil';
        case LegalArea.comercial:
          return 'Comercial';
        case LegalArea.administrativo:
          return 'Administrativo';
        case LegalArea.constitucional:
          return 'Constitucional';
        case LegalArea.ambiental:
          return 'Ambiental';
        case LegalArea.tributario:
          return 'Tributario';
      }
    }).toList();

    return names.join(', ');
  }
}
