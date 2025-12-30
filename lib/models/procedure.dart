enum ProcedureType {
  documentDrafts,   // Creación de borradores
  legalProcedures,  // Trámites jurídicos
  legalConcepts     // Conceptos legales
}

enum DocumentType {
  contracts,        // Contratos
  tutelas,          // Tutelas y/o derechos de petición
  powers            // Poderes
}

enum ProcedureServiceType {
  filing,           // Radicación de documentos
  certificates      // Solicitud de certificados
}

class LegalProcedure {
  final String id;
  final String title;
  final String description;
  final ProcedureType type;
  final DocumentType? documentType;        // Para tipo documentDrafts
  final ProcedureServiceType? serviceType; // Para tipo legalProcedures
  final DateTime createdAt;
  final double estimatedCost;
  final String clientId;
  final String? studentId;
  final bool isCompleted;

  LegalProcedure({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.documentType,
    this.serviceType,
    required this.createdAt,
    required this.estimatedCost,
    required this.clientId,
    this.studentId,
    this.isCompleted = false,
  });

  String get typeName {
    switch (type) {
      case ProcedureType.documentDrafts:
        return 'Creación de borradores de textos jurídicos';
      case ProcedureType.legalProcedures:
        return 'Trámites jurídicos';
      case ProcedureType.legalConcepts:
        return 'Conceptos con respecto a situaciones que involucran derechos';
    }
  }

  String get subtypeName {
    if (documentType != null) {
      switch (documentType!) {
        case DocumentType.contracts:
          return 'Contratos';
        case DocumentType.tutelas:
          return 'Tutelas y/o derechos de petición';
        case DocumentType.powers:
          return 'Poderes';
      }
    }
    
    if (serviceType != null) {
      switch (serviceType!) {
        case ProcedureServiceType.filing:
          return 'Radicación de documentos ante juzgados o entidades públicas';
        case ProcedureServiceType.certificates:
          return 'Solicitud de certificados';
      }
    }
    
    return '';
  }
}

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String location;
  final int semester;
  final String university;
  final bool isVerified;
  final double rating;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.location,
    required this.semester,
    required this.university,
    this.isVerified = false,
    this.rating = 0.0,
  });

  String get fullName => '$firstName $lastName';

  bool get canAcceptProcedures => semester >= 7 && isVerified;
}
