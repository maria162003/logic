import 'package:flutter/foundation.dart';
import '../models/case.dart';
import '../models/lawyer.dart';
import '../models/procedure.dart';

class AppState extends ChangeNotifier {
  int _currentIndex = 0;
  String _userName = 'Usuario';
  bool _isLoggedIn = false;
  int _unreadNotifications = 0;
  int _unreadMessages = 0;
  List<LegalCase> _cases = [];
  List<LegalProcedure> _procedures = [];

  int get currentIndex => _currentIndex;
  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  int get unreadNotifications => _unreadNotifications;
  int get unreadMessages => _unreadMessages;
  List<LegalCase> get cases => _cases;
  List<LegalProcedure> get procedures => _procedures;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setLoginStatus(bool status) {
    _isLoggedIn = status;
    notifyListeners();
  }

  void setUnreadNotifications(int count) {
    _unreadNotifications = count;
    notifyListeners();
  }

  void setUnreadMessages(int count) {
    _unreadMessages = count;
    notifyListeners();
  }

  void addCase(LegalCase legalCase) {
    _cases.add(legalCase);
    notifyListeners();
  }

  void updateCase(LegalCase updatedCase) {
    int index = _cases.indexWhere((c) => c.id == updatedCase.id);
    if (index != -1) {
      _cases[index] = updatedCase;
      notifyListeners();
    }
  }

  void addProcedure(LegalProcedure procedure) {
    _procedures.add(procedure);
    notifyListeners();
  }

  void loadMockData() {
    // Datos de ejemplo para demostración
    final lawyer1 = Lawyer(
      id: 'law1',
      firstName: 'Enrique',
      lastName: 'Villegas',
      location: 'Bogotá',
      type: LawyerType.professional,
      rating: 4.1,
      specialties: [LegalArea.familiar, LegalArea.laboral],
      isVerified: true,
    );
    
    final lawyer2 = Lawyer(
      id: 'law2',
      firstName: 'Andrés',
      lastName: 'López',
      location: 'Medellín',
      type: LawyerType.student,
      rating: 3.7,
      specialties: [LegalArea.familiar, LegalArea.civil],
      semester: 9,
      isVerified: true,
    );
    
    final lawyer3 = Lawyer(
      id: 'law3',
      firstName: 'María',
      lastName: 'González',
      location: 'Cali',
      type: LawyerType.professional,
      rating: 4.5,
      specialties: [LegalArea.familiar],
      isVerified: true,
    );
    
    _cases = [
      // Caso con abogado asignado
      LegalCase(
        id: '1',
        title: 'Divorcio de mutuo acuerdo',
        description: 'Necesito asesoría para proceso de divorcio con acuerdo de ambas partes sobre custodia y división de bienes.',
        area: LegalArea.familiar,
        status: CaseStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        daysElapsed: 90,
        progressPercentage: 50,
        offersCount: 0,
        assignedLawyer: lawyer1,
        updates: [
          CaseUpdate(
            id: 'u1',
            status: CaseStatus.preparation,
            date: DateTime.now().subtract(const Duration(days: 90)),
          ),
          CaseUpdate(
            id: 'u2',
            status: CaseStatus.inProgress,
            date: DateTime.now().subtract(const Duration(days: 60)),
          ),
        ],
      ),
      
      // Caso pendiente con ofertas
      LegalCase(
        id: '2',
        title: 'Demanda laboral por despido injustificado',
        description: 'Fui despedido sin justa causa y necesito asesoría legal para proceder con demanda laboral. Tengo todos los documentos y comprobantes de mi relación laboral.',
        area: LegalArea.laboral,
        status: CaseStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        daysElapsed: 0,
        progressPercentage: 0,
        offersCount: 3,
        offers: [
          CaseOffer(
            id: 'off1',
            caseId: '2',
            lawyer: lawyer1,
            message: 'Estimado cliente, he revisado su caso y cuento con amplia experiencia en derecho laboral. He manejado casos similares de despido injustificado con resultados exitosos. Mi estrategia incluiría la recopilación de toda la documentación pertinente, análisis del contrato laboral, y preparación de demanda ante el juez laboral correspondiente. Garantizo atención personalizada y comunicación constante durante todo el proceso.',
            honorarios: 3500000,
            estimatedDays: 120,
            paymentType: PaymentType.twoPayments,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          CaseOffer(
            id: 'off2',
            caseId: '2',
            lawyer: lawyer2,
            message: 'Hola, soy estudiante de derecho en 9° semestre con prácticas en derecho laboral. Puedo ayudarte con tu caso a un costo más económico. Trabajaré bajo la supervisión de un abogado titular y me comprometo a dar mi mejor esfuerzo.',
            honorarios: 1200000,
            estimatedDays: 90,
            paymentType: PaymentType.divided,
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          CaseOffer(
            id: 'off3',
            caseId: '2',
            lawyer: lawyer3,
            message: 'Buenas tardes, especialista en derecho laboral con 15 años de experiencia. Ofrezco pago por resultado, cobrando un porcentaje solo si ganamos el caso. Esto elimina riesgos económicos para usted.',
            honorarios: 0,
            estimatedDays: 150,
            paymentType: PaymentType.byResult,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
      
      // Caso en preparación
      LegalCase(
        id: '3',
        title: 'Custodia compartida de menores',
        description: 'Necesito establecer régimen de custodia compartida con mi ex pareja. Buscamos lo mejor para nuestros hijos.',
        area: LegalArea.familiar,
        status: CaseStatus.preparation,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        daysElapsed: 30,
        progressPercentage: 25,
        offersCount: 0,
        assignedLawyer: lawyer3,
        updates: [
          CaseUpdate(
            id: 'u3',
            status: CaseStatus.preparation,
            date: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
      ),
    ];
    
    _unreadNotifications = 2;
    _unreadMessages = 1;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = 'Usuario';
    _currentIndex = 0;
    _unreadNotifications = 0;
    _unreadMessages = 0;
    _cases = [];
    _procedures = [];
    notifyListeners();
  }
}