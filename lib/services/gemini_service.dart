import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  late GenerativeModel _model;
  late ChatSession _chatSession;
  String _currentModel = 'gemini-2.0-flash';

  GeminiService() {
    _initializeModel('gemini-2.0-flash');
  }

  void _initializeModel(String modelName) {
    _currentModel = modelName;
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.6,
        topK: 40,
        topP: 0.9,
        maxOutputTokens: 600, // Respuestas más cortas
      ),
    );
    _initializeChatSession();
  }

  Future<void> initializeWithModel(String modelName) async {
    _initializeModel(modelName);
  }

  // Método para probar múltiples modelos automáticamente
  Future<String> _testModelAndRespond(String message) async {
    final modelsToTry = [
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-pro',
    ];

    for (final model in modelsToTry) {
      try {
        print('🔄 Probando modelo: $model');
        _initializeModel(model);

        final response = await _chatSession.sendMessage(Content.text(message));
        final result = response.text ?? 'Lo siento, no pude procesar tu consulta.';

        print('✅ Modelo $model funcionó correctamente');
        return _cleanResponse(result);
      } catch (e) {
        print('❌ Modelo $model falló: $e');
        continue;
      }
    }

    return 'Lo siento, hay un problema temporal. Por favor intenta más tarde.';
  }

  /// Limpia la respuesta de caracteres extraños y formato Markdown
  String _cleanResponse(String text) {
    String cleaned = text;
    
    // Remover markdown de negrita y cursiva
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'_([^_]+)_'), r'$1');
    
    // Remover headers markdown
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remover backticks de código
    cleaned = cleaned.replaceAll(RegExp(r'```[a-z]*\n?'), '');
    cleaned = cleaned.replaceAll('`', '');
    
    // Remover viñetas markdown y convertir a formato limpio
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '• ');
    
    // Limpiar numeración excesiva (1. 2. etc) y mantener formato simple
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '→ ');
    
    // Remover líneas vacías múltiples
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Remover espacios al inicio y final
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  void _initializeChatSession() {
    _chatSession = _model.startChat(history: [
      Content.text('''
Eres el asistente legal de Logic Lex para Colombia. REGLAS ESTRICTAS:

1. RESPUESTAS CORTAS: Máximo 3-4 párrafos. Sé conciso y directo.
2. LENGUAJE SIMPLE: Usa español sencillo, evita tecnicismos. Si usas uno, explícalo brevemente.
3. SIN FORMATO ESPECIAL: No uses asteriscos, guiones bajos, hashtags ni markdown.
4. ESTRUCTURA CLARA: Usa viñetas simples (•) y flechas (→) para pasos.
5. SIEMPRE termina con: "Te recomiendo consultar con un abogado para tu caso específico."

Eres amigable, empático y profesional. Responde como si hablaras con un amigo que necesita ayuda legal.
'''),
    ]);
  }

  Future<String> sendMessage(String message) async {
    try {
      print('🤖 Gemini: Enviando mensaje con modelo: $_currentModel');

      final enhancedMessage = '''
Responde de forma BREVE y SIMPLE a esta consulta:

"$message"

Recuerda: máximo 3-4 párrafos, sin formato markdown, lenguaje sencillo.
''';

      final response = await _chatSession.sendMessage(
        Content.text(enhancedMessage),
      );

      final result = response.text ?? 'Lo siento, no pude procesar tu consulta.';
      print('🤖 Gemini: Respuesta recibida exitosamente');
      return _cleanResponse(result);
    } catch (e) {
      print('❌ Error con modelo $_currentModel: $e');
      return await _testModelAndRespond(message);
    }
  }

  Future<String> getLegalAdvice(String legalArea, String question) async {
    final prompt = '''
Como asistente de $legalArea, responde BREVEMENTE:

Pregunta: $question

Da una respuesta corta y práctica (máximo 4 párrafos):
• Explica el tema en términos simples
• Menciona los pasos principales
• Indica qué documentos podrían necesitarse
• Recomienda consultar un abogado

SIN formato markdown. Lenguaje sencillo y directo.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _cleanResponse(response.text ?? 'No pude generar una respuesta.');
    } catch (e) {
      print('Error en consulta legal: $e');
      return 'Error al procesar la consulta. Intenta nuevamente.';
    }
  }

  Future<String> explainLegalTerm(String term) async {
    final prompt = '''
Explica en 2-3 oraciones simples qué significa "$term" en el contexto legal colombiano.

Sin formato markdown. Como si le explicaras a un amigo.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _cleanResponse(response.text ?? 'No pude explicar ese término.');
    } catch (e) {
      print('Error explicando término: $e');
      return 'Error al explicar el término legal.';
    }
  }

  Future<String> analyzeDocument(String documentType, String content) async {
    final prompt = '''
Analiza brevemente este documento de tipo "$documentType":

$content

En máximo 3 párrafos:
• Resumen del contenido
• Puntos importantes
• Una recomendación

Sin formato markdown.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _cleanResponse(response.text ?? 'No pude analizar el documento.');
    } catch (e) {
      print('Error analizando documento: $e');
      return 'Error al analizar el documento.';
    }
  }

  Future<List<String>> getSuggestedQuestions(String legalArea) async {
    final prompt = '''
Dame 5 preguntas cortas y comunes sobre $legalArea.
Solo las preguntas, una por línea, sin números ni viñetas.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return text.split('\n').where((line) => line.trim().isNotEmpty).take(5).toList();
    } catch (e) {
      return [
        '¿Cuáles son mis derechos?',
        '¿Qué documentos necesito?',
        '¿Cuánto tiempo toma?',
        '¿Cuáles son los costos?',
        '¿Qué pasos debo seguir?'
      ];
    }
  }

  /// Método especial para el asistente de la app
  Future<String> getAppAssistance(String question, String currentScreen) async {
    final prompt = '''
Eres el asistente de ayuda de Logic Lex. El usuario está en: "$currentScreen"

Pregunta del usuario: "$question"

FUNCIONES DE LA APP:
• Publicar caso legal: Describe tu situación y recibe propuestas de abogados
• Buscar abogados: Encuentra abogados por especialidad y ubicación
• Chat con IA: Consultas legales básicas (donde estamos ahora)
• Trámites jurídicos: Solicita ayuda de estudiantes de derecho verificados
• Mis casos: Ve el estado de tus casos publicados
• Configuración: Ajusta tu perfil y preferencias

Responde en 2-3 oraciones cómo puede hacer lo que pregunta. Si necesita ir a otra pantalla, dile cuál.
Sé muy breve y directo. Sin formato markdown.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _cleanResponse(response.text ?? 'No pude entender tu pregunta. ¿Puedes reformularla?');
    } catch (e) {
      return 'Lo siento, tuve un problema. Intenta preguntarme de otra forma.';
    }
  }

  void resetChat() {
    _initializeChatSession();
  }
}
