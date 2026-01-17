import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  LegalArea? _selectedArea;
  bool _isAppHelpMode = false; // Modo de ayuda de la app

  /// Limpieza exhaustiva de formato Markdown y caracteres extraños
  String _cleanMarkdownFormatting(String text) {
    String cleaned = text;
    
    // Remover negrita (**texto** o *texto*)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    
    // Remover itálica (__texto__ o _texto_)
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'(?<![a-zA-Z])_([^_]+)_(?![a-zA-Z])'), r'$1');
    
    // Remover headers markdown (# ## ### etc)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remover código inline y bloques de código
    cleaned = cleaned.replaceAll(RegExp(r'```[a-z]*\n?'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'$1');
    
    // Convertir listas markdown a viñetas simples
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '• ');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '→ ');
    
    // Remover links markdown [texto](url)
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    
    // Limpiar múltiples líneas vacías
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Remover caracteres de control extraños
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    
    return cleaned.trim();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  LegalArea? get selectedArea => _selectedArea;
  bool get isAppHelpMode => _isAppHelpMode;

  void setSelectedArea(LegalArea? area) {
    _selectedArea = area;
    notifyListeners();
  }

  /// Activa/desactiva el modo de ayuda de la app
  void setAppHelpMode(bool enabled) {
    _isAppHelpMode = enabled;
    notifyListeners();
  }

  Future<void> sendMessage(String content, {String currentScreen = 'Chat IA'}) async {
    if (content.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    notifyListeners();

    // Mostrar indicador de escritura
    _isLoading = true;
    final typingMessage = ChatMessage.typing();
    _messages.add(typingMessage);
    notifyListeners();

    try {
      String response;

      // Determinar el tipo de consulta
      if (_isAppHelpMode) {
        // Modo ayuda de la app
        response = await _geminiService.getAppAssistance(content, currentScreen);
      } else if (_selectedArea != null) {
        response = await _geminiService.getLegalAdvice(_selectedArea!.name, content);
      } else {
        response = await _geminiService.sendMessage(content);
      }

      // Remover indicador de escritura
      _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);

      // Limpiar formato Markdown y agregar respuesta de la IA
      final cleanedResponse = _cleanMarkdownFormatting(response);
      final aiMessage = ChatMessage.ai(
        cleanedResponse,
        type: _selectedArea != null ? ChatMessageType.legalAdvice : ChatMessageType.text,
      );
      _messages.add(aiMessage);
    } catch (e) {
      // Remover indicador de escritura
      _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);

      // Agregar mensaje de error
      final errorMessage = ChatMessage.ai(
        'Disculpa, hubo un error al procesar tu consulta. Por favor, intenta nuevamente.',
        type: ChatMessageType.error,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> explainTerm(String term) async {
    _isLoading = true;
    final typingMessage = ChatMessage.typing();
    _messages.add(typingMessage);
    notifyListeners();

    try {
      final explanation = await _geminiService.explainLegalTerm(term);

      // Remover indicador de escritura
      _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);

      // Limpiar formato Markdown
      final cleanedExplanation = _cleanMarkdownFormatting(explanation);
      final explanationMessage = ChatMessage.ai(
        cleanedExplanation,
        type: ChatMessageType.termExplanation,
      );
      _messages.add(explanationMessage);
    } catch (e) {
      _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);
      final errorMessage = ChatMessage.ai(
        'No pude explicar ese término. Intenta nuevamente.',
        type: ChatMessageType.error,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeDocument(String documentType, String content) async {
    _isLoading = true;
    final typingMessage = ChatMessage.typing();
    _messages.add(typingMessage);
    notifyListeners();

    try {
      final analysis = await _geminiService.analyzeDocument(documentType, content);

      _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);

      // Limpiar formato Markdown
      final cleanedAnalysis = _cleanMarkdownFormatting(analysis);
      final analysisMessage = ChatMessage.ai(
        cleanedAnalysis,
        type: ChatMessageType.documentAnalysis,
      );
      _messages.add(analysisMessage);
    } catch (e) {
      _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);
      final errorMessage = ChatMessage.ai(
        'No pude analizar el documento. Intenta nuevamente.',
        type: ChatMessageType.error,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSuggestions() async {
    if (_selectedArea == null) return;

    try {
      final suggestions = await _geminiService.getSuggestedQuestions(_selectedArea!.name);

      for (final suggestion in suggestions.take(3)) {
        // Limpiar formato Markdown
        final cleanedSuggestion = _cleanMarkdownFormatting(suggestion);
        final suggestionMessage = ChatMessage.ai(
          cleanedSuggestion,
          type: ChatMessageType.suggestion,
        );
        _messages.add(suggestionMessage);
      }

      notifyListeners();
    } catch (e) {
      print('Error obteniendo sugerencias: $e');
    }
  }

  void clearChat() {
    _messages.clear();
    _geminiService.resetChat();
    notifyListeners();
  }

  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage.ai(
        '👋 ¡Hola! Soy Logic AI, tu asistente legal virtual.\n\n'
        'Puedo ayudarte con:\n'
        '• Consultas legales generales\n'
        '• Explicación de términos jurídicos\n'
        '• Información sobre procedimientos\n'
        '• Análisis básico de documentos\n\n'
        '¿En qué área legal te puedo ayudar hoy?',
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }

  void removeMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  bool get isTyping => _isLoading;
}
