import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  LegalArea? _selectedArea;

  // Función para limpiar formato Markdown de los mensajes
  String _cleanMarkdownFormatting(String text) {
    // Remover asteriscos de negrita (**texto** o *texto*)
    String cleaned = text.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    // Remover guiones bajos de itálica (__texto__ o _texto_)
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'_([^_]+)_'), r'$1');
    return cleaned;
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  LegalArea? get selectedArea => _selectedArea;

  void setSelectedArea(LegalArea? area) {
    _selectedArea = area;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
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

      // Determinar el tipo de consulta y usar el método apropiado
      if (_selectedArea != null) {
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
