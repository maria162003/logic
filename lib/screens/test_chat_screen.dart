import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_models.dart';

class TestChatScreen extends StatefulWidget {
  const TestChatScreen({super.key});

  @override
  State<TestChatScreen> createState() => _TestChatScreenState();
}

class _TestChatScreenState extends State<TestChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Test Chat Gemini')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu consulta legal...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) => _send(chat),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: chat.isTyping ? null : () => _send(chat),
                  child: const Text('Enviar'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages[index];
                if (msg.type == ChatMessageType.typing) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('La IA está escribiendo...'),
                  );
                }
                return ListTile(
                  leading: Icon(msg.isUser ? Icons.person : Icons.smart_toy),
                  title: Text(msg.content),
                  subtitle: Text(msg.isUser ? 'Usuario' : 'IA'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _send(ChatProvider chat) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    chat.sendMessage(text);
    _controller.clear();
  }
}
