import 'package:flutter/material.dart';
import 'lawyer.dart';

enum CaseStatus {
  pending,        // Pendiente (sin abogado asignado)
  preparation,    // En preparación
  inProgress,     // En trámite
  completed       // Terminado
}

enum LegalArea {
  familiar,
  laboral,
  penal,
  civil,
  comercial,
  administrativo,
  constitucional,
  ambiental,
  tributario
}

class LegalCase {
  final String id;
  final String title;
  final String description;
  final LegalArea area;
  final CaseStatus status;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final Lawyer? assignedLawyer;
  final int offersCount;
  final List<CaseOffer> offers;
  final double? budget;
  final String? location;
  final int daysElapsed;
  final double progressPercentage;
  final List<CaseUpdate> updates;

  LegalCase({
    required this.id,
    required this.title,
    required this.description,
    required this.area,
    required this.status,
    required this.createdAt,
    this.lastUpdated,
    this.assignedLawyer,
    this.offersCount = 0,
    this.offers = const [],
    this.budget,
    this.location,
    this.daysElapsed = 0,
    this.progressPercentage = 0.0,
    this.updates = const [],
  });

  String get areaName {
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
  }

  Color get areaColor {
    switch (area) {
      case LegalArea.familiar:
        return const Color(0xFF9C27B0); // Púrpura
      case LegalArea.laboral:
        return const Color(0xFF2196F3); // Azul
      case LegalArea.penal:
        return const Color(0xFFF44336); // Rojo
      case LegalArea.civil:
        return const Color(0xFF4CAF50); // Verde
      case LegalArea.comercial:
        return const Color(0xFFFF9800); // Naranja
      case LegalArea.administrativo:
        return const Color(0xFF795548); // Café
      case LegalArea.constitucional:
        return const Color(0xFF00BCD4); // Cyan
      case LegalArea.ambiental:
        return const Color(0xFF8BC34A); // Verde claro
      case LegalArea.tributario:
        return const Color(0xFFFFEB3B); // Amarillo
    }
  }

  IconData get areaIcon {
    switch (area) {
      case LegalArea.familiar:
        return Icons.family_restroom;
      case LegalArea.laboral:
        return Icons.work;
      case LegalArea.penal:
        return Icons.gavel;
      case LegalArea.civil:
        return Icons.account_balance;
      case LegalArea.comercial:
        return Icons.business;
      case LegalArea.administrativo:
        return Icons.admin_panel_settings;
      case LegalArea.constitucional:
        return Icons.policy;
      case LegalArea.ambiental:
        return Icons.eco;
      case LegalArea.tributario:
        return Icons.attach_money;
    }
  }

  String get statusName {
    switch (status) {
      case CaseStatus.pending:
        return 'Pendiente';
      case CaseStatus.preparation:
        return 'En preparación';
      case CaseStatus.inProgress:
        return 'En trámite';
      case CaseStatus.completed:
        return 'Terminado';
    }
  }

  Color get statusColor {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.preparation:
        return Colors.blue;
      case CaseStatus.inProgress:
        return Colors.purple;
      case CaseStatus.completed:
        return Colors.green;
    }
  }
}

enum PaymentType {
  full,           // Único pago de la totalidad
  divided,        // Pagos divididos durante el proceso
  twoPayments,    // Dos pagos: inicio y final
  byResult        // Pago por resultado
}

class CaseOffer {
  final String id;
  final String caseId;
  final Lawyer lawyer;
  final String message;
  final double honorarios;
  final int estimatedDays;
  final PaymentType paymentType;
  final DateTime createdAt;
  final bool isAccepted;
  final bool isRejected;

  CaseOffer({
    required this.id,
    required this.caseId,
    required this.lawyer,
    required this.message,
    required this.honorarios,
    required this.estimatedDays,
    required this.paymentType,
    required this.createdAt,
    this.isAccepted = false,
    this.isRejected = false,
  });

  String get paymentTypeName {
    switch (paymentType) {
      case PaymentType.full:
        return 'Único pago de la totalidad al comienzo del proceso';
      case PaymentType.divided:
        return 'Pagos divididos durante el proceso';
      case PaymentType.twoPayments:
        return 'Dos pagos: uno para empezar y otro para la finalización';
      case PaymentType.byResult:
        return 'Pago por resultado (porcentaje de la ganancia económica)';
    }
  }
}

class CaseUpdate {
  final String id;
  final CaseStatus status;
  final DateTime date;
  final String? notes;

  CaseUpdate({
    required this.id,
    required this.status,
    required this.date,
    this.notes,
  });
}
