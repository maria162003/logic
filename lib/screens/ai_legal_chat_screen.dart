import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/chat_provider.dart';
import '../models/chat_models.dart';
import '../widgets/ad_banner_widget.dart';

class AILegalChatScreen extends StatefulWidget {
  const AILegalChatScreen({super.key});

  @override
  State<AILegalChatScreen> createState() => _AILegalChatScreenState();
}

class _AILegalChatScreenState extends State<AILegalChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showAd = false;
  
  @override
  void initState() {
    super.initState();
    // Scroll automático al final cuando lleguen mensajes nuevos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return Text(
              chatProvider.isAppHelpMode ? 'Ayuda de la App' : 'Asistente Legal IA',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            );
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón para cambiar entre modos
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return IconButton(
                icon: Icon(
                  chatProvider.isAppHelpMode ? Icons.gavel : Icons.help_outline,
                  color: AppColors.onPrimary,
                ),
                tooltip: chatProvider.isAppHelpMode ? 'Modo Legal' : 'Ayuda de la App',
                onPressed: () {
                  chatProvider.setAppHelpMode(!chatProvider.isAppHelpMode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        chatProvider.isAppHelpMode 
                          ? '🎓 Modo Ayuda: Pregúntame cómo usar la app'
                          : '⚖️ Modo Legal: Consultas sobre derecho',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: _buildChatArea(),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final isHelpMode = chatProvider.isAppHelpMode;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHelpMode ? Colors.blue[50] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isHelpMode ? Colors.blue : AppColors.primary,
                radius: 20,
                child: Icon(
                  isHelpMode ? Icons.support_agent : Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHelpMode ? 'Asistente de Logic Lex' : 'Asistente Legal IA',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      isHelpMode 
                        ? '¿Cómo puedo ayudarte a usar la app?' 
                        : 'Especializado en derecho colombiano',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isHelpMode ? Colors.blue[600] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHelpMode ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isHelpMode ? Colors.blue : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHelpMode ? 'Ayuda' : 'En línea',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isHelpMode ? Colors.blue[700] : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatArea() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Scroll al final cuando cambian los mensajes
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: chatProvider.messages.isEmpty
              ? _buildWelcomeMessage()
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    
                    // Mostrar indicador de escritura para mensajes tipo typing
                    if (message.type == ChatMessageType.typing) {
                      return _buildTypingIndicator();
                    }
                    
                    return _buildChatMessage(message);
                  },
                ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final isHelpMode = chatProvider.isAppHelpMode;
        
        if (isHelpMode) {
          return _buildAppHelpWelcome();
        }
        
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  size: 70,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Hola! Soy tu Asistente Legal',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Powered by Google Gemini',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Te doy respuestas simples y directas\nsobre derecho colombiano',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Puedes preguntarme sobre:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                _buildTopicChips(),
                const SizedBox(height: 16),
                // Tip para cambiar a modo ayuda
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Toca el ícono ? arriba para aprender a usar la app',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.blue[700],
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
      },
    );
  }

  Widget _buildAppHelpWelcome() {
    final helpTopics = [
      {'icon': Icons.add_circle, 'text': '¿Cómo publico un caso?', 'action': 'publicar_caso'},
      {'icon': Icons.search, 'text': '¿Cómo busco un abogado?', 'action': 'buscar_abogado'},
      {'icon': Icons.description, 'text': '¿Qué son los trámites jurídicos?', 'action': 'tramites'},
      {'icon': Icons.visibility, 'text': '¿Cómo veo mis casos?', 'action': 'ver_casos'},
      {'icon': Icons.mail, 'text': '¿Cómo respondo a propuestas?', 'action': 'propuestas'},
      {'icon': Icons.settings, 'text': '¿Cómo configuro mi perfil?', 'action': 'configuracion'},
    ];

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 70,
              color: Colors.blue.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Hola! Te ayudo a usar Logic Lex',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pregúntame cómo hacer cualquier cosa\nen la aplicación',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Preguntas frecuentes:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: helpTopics.map((topic) {
                return GestureDetector(
                  onTap: () => _sendMessage(topic['text'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(topic['icon'] as IconData, size: 16, color: Colors.blue[600]),
                        const SizedBox(width: 6),
                        Text(
                          topic['text'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Tip para volver al modo legal
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.gavel, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca el ícono ⚖️ arriba para consultas legales',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[700],
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

  Widget _buildTopicChips() {
    final topics = [
      '¿Qué es una tutela?',
      '¿Cómo funciona una sucesión?',
      'Derechos laborales básicos',
      'Proceso de divorcio',
      'Cuota de alimentos',
      'Contratos en Colombia',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: topics.map((topic) {
        return GestureDetector(
          onTap: () => _sendMessage(topic),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              topic,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.psychology,
                size: 16,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 12),
                ),
              ),
              child: Text(
                message.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isUser ? AppColors.onPrimary : Colors.grey[800],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Banner publicitario mientras la IA responde
        AdBannerWidget(
          showSkipButton: true,
          minDisplaySeconds: 3,
          onAdComplete: () {
            // El anuncio se cierra automáticamente
          },
          onAdSkip: () {
            // Usuario saltó el anuncio
          },
        ),
        
        const SizedBox(height: 8),
        
        // Indicador de que la IA está escribiendo
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.psychology,
                  size: 16,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'El asistente está escribiendo...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu consulta legal...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.primary),
                    onPressed: () => _sendMessage(_chatController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatController.clear();
    
    // Enviar mensaje al provider que maneja Gemini
    await chatProvider.sendMessage(text);
  }
}
