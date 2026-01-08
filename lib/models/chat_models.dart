class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
    this.metadata,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String content, {ChatMessageType? type}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: type ?? ChatMessageType.text,
    );
  }

  factory ChatMessage.typing() {
    return ChatMessage(
      id: 'typing',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      type: ChatMessageType.typing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: ChatMessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChatMessageType.text,
      ),
      metadata: json['metadata'],
    );
  }
}

enum ChatMessageType {
  text,
  legalAdvice,
  documentAnalysis,
  termExplanation,
  suggestion,
  typing,
  error,
}

class LegalArea {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> commonQuestions;

  const LegalArea({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.commonQuestions,
  });

  static const List<LegalArea> areas = [
    LegalArea(
      id: 'civil',
      name: 'Derecho Civil',
      description: 'Contratos, propiedad, obligaciones',
      icon: '📝',
      commonQuestions: [
        '¿Cómo redactar un contrato?',
        '¿Qué es la prescripción adquisitiva?',
        '¿Cómo registrar una propiedad?',
      ],
    ),
    LegalArea(
      id: 'laboral',
      name: 'Derecho Laboral',
      description: 'Relaciones laborales, despidos, prestaciones',
      icon: '💼',
      commonQuestions: [
        '¿Cuáles son mis prestaciones sociales?',
        '¿Me pueden despedir sin justa causa?',
        '¿Cómo calcular mi liquidación?',
      ],
    ),
    LegalArea(
      id: 'familia',
      name: 'Derecho de Familia',
      description: 'Divorcio, custodia, alimentos',
      icon: '👨‍👩‍👧‍👦',
      commonQuestions: [
        '¿Cómo tramitar un divorcio?',
        '¿Qué es la cuota alimentaria?',
        '¿Cómo se determina la custodia?',
      ],
    ),
    LegalArea(
      id: 'penal',
      name: 'Derecho Penal',
      description: 'Delitos, defensas, procesos penales',
      icon: '⚖️',
      commonQuestions: [
        '¿Cuáles son mis derechos al ser detenido?',
        '¿Qué es un preacuerdo?',
        '¿Cómo funciona la libertad condicional?',
      ],
    ),
    LegalArea(
      id: 'constitucional',
      name: 'Derecho Constitucional',
      description: 'Tutelas, derechos fundamentales',
      icon: '🏛️',
      commonQuestions: [
        '¿Qué es una acción de tutela?',
        '¿Cuándo procede una tutela?',
        '¿Cómo presentar una tutela?',
      ],
    ),
  ];
}
