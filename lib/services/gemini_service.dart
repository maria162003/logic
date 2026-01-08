import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyCklRzYjE6wHJaytJe3qo8UXuOKLcoRzdI';
  late GenerativeModel _model;
  late ChatSession _chatSession;
  String _currentModel = 'gemini-2.5-flash';

  GeminiService() {
    _initializeModel('gemini-2.5-flash');
  }

  void _initializeModel(String modelName) {
    _currentModel = modelName;
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
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
      'gemini-2.5-flash',
      'gemini-2.5-pro',
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
        return result;
      } catch (e) {
        print('❌ Modelo $model falló: $e');
        continue;
      }
    }

    return 'Lo siento, hay un problema temporal con el servicio de IA. '
        'Por favor intenta más tarde o contacta directamente a un abogado.';
  }

  void _initializeChatSession() {
    _chatSession = _model.startChat(history: [
      Content.text(
        'Eres un asistente legal para Colombia. Responde de manera profesional y clara.'
      ),
    ]);
  }

  Future<String> sendMessage(String message) async {
    // Primero intentar con el modelo actual
    try {
      print('🤖 Gemini: Enviando mensaje con modelo: $_currentModel');
      print('🤖 Gemini: API Key configurada: ${_apiKey.substring(0, 10)}...');

      final response = await _chatSession.sendMessage(
        Content.text(message),
      );

      final result = response.text ?? 'Lo siento, no pude procesar tu consulta.';
      print('🤖 Gemini: Respuesta recibida exitosamente con $_currentModel');
      return result;
    } catch (e) {
      print('❌ Error con modelo $_currentModel: $e');
      print('🔄 Probando con otros modelos...');

      // Si falla, probar automáticamente con otros modelos
      return await _testModelAndRespond(message);
    }
  }

  Future<String> getLegalAdvice(String legalArea, String question) async {
    final prompt = '''
    Como asistente legal especializado en $legalArea, responde a la siguiente consulta:
    
    Pregunta: $question
    
    Por favor proporciona:
    1. Una explicación clara del tema legal
    2. Los pasos generales que se suelen seguir
    3. Documentos que podrían necesitarse
    4. Recomendación de consultar con un abogado especializado
    
    Recuerda que esta es información general educativa, no consejo legal específico.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No pude generar una respuesta adecuada.';
    } catch (e) {
      print('Error en consulta legal: $e');
      return 'Error al procesar la consulta legal. Intenta nuevamente.';
    }
  }

  Future<String> explainLegalTerm(String term) async {
    final prompt = '''
    Explica de manera clara y sencilla el término legal: "$term"
    
    Incluye:
    - Definición en términos simples
    - Contexto donde se usa
    - Ejemplo práctico si es posible
    - Relevancia en el derecho colombiano
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No pude explicar ese término.';
    } catch (e) {
      print('Error explicando término: $e');
      return 'Error al explicar el término legal.';
    }
  }

  Future<String> analyzeDocument(String documentType, String content) async {
    final prompt = '''
    Analiza el siguiente documento de tipo "$documentType":
    
    $content
    
    Proporciona:
    1. Un resumen del contenido
    2. Puntos importantes a considerar
    3. Posibles riesgos o beneficios
    4. Recomendaciones generales
    
    Nota: Este es un análisis informativo, no constituye asesoría legal.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No pude analizar el documento.';
    } catch (e) {
      print('Error analizando documento: $e');
      return 'Error al analizar el documento.';
    }
  }

  Future<List<String>> getSuggestedQuestions(String legalArea) async {
    final prompt = '''
    Genera 5 preguntas frecuentes sobre $legalArea que los usuarios suelen hacer.
    Devuelve solo las preguntas, una por línea, sin numeración.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    } catch (e) {
      print('Error generando sugerencias: $e');
      return [
        '¿Cuáles son mis derechos en esta situación?',
        '¿Qué documentos necesito para este trámite?',
        '¿Cuánto tiempo toma este proceso legal?',
        '¿Cuáles son los costos asociados?',
        '¿Qué pasos debo seguir?'
      ];
    }
  }

  void resetChat() {
    _initializeChatSession();
  }
}
