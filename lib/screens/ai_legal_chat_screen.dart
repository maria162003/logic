import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/chat_provider.dart';
import '../models/chat_models.dart';

class AILegalChatScreen extends StatefulWidget {
  const AILegalChatScreen({super.key});

  @override
  State<AILegalChatScreen> createState() => _AILegalChatScreenState();
}

class _AILegalChatScreenState extends State<AILegalChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
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
        title: Text(
          'Asistente Legal IA',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            backgroundColor: AppColors.primary,
            radius: 20,
            child: Icon(
              Icons.psychology,
              color: AppColors.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente Legal IA',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Especializado en derecho colombiano',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'En línea',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Hola! Soy tu Asistente Legal IA',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
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
                Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Powered by Google Gemini',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Especializado en derecho colombiano',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Puedes preguntarme sobre:',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          _buildTopicChips(),
          const SizedBox(height: 24),
          Text(
            'Escribe tu consulta legal abajo',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
    return Container(
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
