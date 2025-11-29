import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Servicio de filtrado de contenido para prevenir intercambio de datos personales
class ContentFilter {
  // Patrones de detección mejorados para Colombia
  static final Map<String, RegExp> _patterns = {
    'phone': RegExp(r'\b(?:\+?57\s?)?[0-9\s\-\(\)]{8,15}\b'), // Números telefónicos
    'email': RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Correos
    'cellphone': RegExp(r'\b(?:3[0-9]{2}|31[0-9]|32[0-9]|30[0-9])\s?[0-9]{7}\b'), // Celulares colombianos
    'landline': RegExp(r'\b[1-8][0-9]{6,7}\b'), // Teléfonos fijos
    'whatsapp': RegExp(r'\b(?:whatsapp|wsp|wa)\s?:?\s?[0-9\+\s\-\(\)]{8,15}\b', caseSensitive: false),
    'telegram': RegExp(r'\b(?:telegram|tg)\s?:?\s?[@a-zA-Z0-9_]{3,}\b', caseSensitive: false),
    'social_handle': RegExp(r'@[a-zA-Z0-9_]{3,}'), // Handles de redes sociales
    'url_with_contact': RegExp(r'\b(?:https?://)?(?:www\.)?(?:facebook|instagram|twitter|linkedin|tiktok)\.com/[a-zA-Z0-9._-]+\b', caseSensitive: false),
    'credit_card': RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Tarjetas de crédito
    'cedula': RegExp(r'\b\d{6,10}\b'), // Números de cédula (puede ser muy amplio)
  };

  // Palabras clave que sugieren intercambio de contacto
  static final List<RegExp> _contactKeywords = [
    RegExp(r'\b(?:mi\s+)?(?:número|numero|telefono|teléfono|celular|cel)\s*(?:es|:)?\s*', caseSensitive: false),
    RegExp(r'\b(?:mi\s+)?(?:correo|email|mail|gmail|hotmail|outlook)\s*(?:es|:)?\s*', caseSensitive: false),
    RegExp(r'\b(?:escribeme|escríbeme|contactame|contáctame|llámame|llamame)\b', caseSensitive: false),
    RegExp(r'\b(?:whatsapp|whatssap|wsp|wa|telegram|tg)\s*(?:es|:)?\s*', caseSensitive: false),
    RegExp(r'\b(?:mi\s+)?(?:instagram|insta|facebook|face|twitter|linkedin)\s*(?:es|:)?\s*', caseSensitive: false),
    RegExp(r'\b(?:dame|dime)\s+(?:tu|tus)\s+(?:datos|contacto|numero|correo)\b', caseSensitive: false),
    RegExp(r'\b(?:como|cómo)\s+(?:te|puedo)\s+(?:contacto|contactar|localizo|localizar|ubico|ubicar)\b', caseSensitive: false),
  ];

  // Mensajes de advertencia específicos
  static const Map<String, String> _warningMessages = {
    'phone': '⚠️ No se permiten números de teléfono en el chat',
    'email': '⚠️ No se permiten correos electrónicos en el chat',
    'cellphone': '⚠️ No se permiten números de celular en el chat',
    'landline': '⚠️ No se permiten números de teléfono fijo en el chat',
    'whatsapp': '⚠️ No se permite compartir WhatsApp en el chat',
    'telegram': '⚠️ No se permite compartir Telegram en el chat',
    'social_handle': '⚠️ No se permiten handles de redes sociales',
    'url_with_contact': '⚠️ No se permiten enlaces a redes sociales personales',
    'contact_keyword': '⚠️ No se permite solicitar información de contacto',
    'credit_card': '⚠️ No se permite compartir información financiera',
    'cedula': '⚠️ No se permite compartir números de identificación',
  };

  /// Verifica si el texto contiene contenido prohibido
  static String? checkContent(String text) {
    // Verificar patrones específicos
    for (MapEntry<String, RegExp> entry in _patterns.entries) {
      if (entry.value.hasMatch(text)) {
        return entry.key;
      }
    }
    
    // Verificar palabras clave de contacto
    for (RegExp keyword in _contactKeywords) {
      if (keyword.hasMatch(text)) {
        return 'contact_keyword';
      }
    }
    
    return null; // No se encontró contenido prohibido
  }

  /// Obtiene el mensaje de advertencia para un tipo de violación
  static String getWarningMessage(String violationType) {
    return _warningMessages[violationType] ?? '⚠️ Contenido no permitido';
  }

  /// Muestra una advertencia de contenido filtrado
  static void showWarning(BuildContext context, String violationType) {
    final message = getWarningMessage(violationType);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.security, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Por seguridad, usa los canales oficiales de la app para contactar',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Entendido',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Limpia el texto removiendo el contenido prohibido
  static String cleanText(String text) {
    String cleanedText = text;
    
    // Reemplazar patrones específicos con asteriscos
    _patterns.forEach((type, pattern) {
      cleanedText = cleanedText.replaceAll(pattern, '[CONTENIDO FILTRADO]');
    });
    
    return cleanedText;
  }
}

/// InputFormatter que utiliza ContentFilter
class ContentSafetyInputFormatter extends TextInputFormatter {
  final Function(String)? onContentBlocked;
  
  ContentSafetyInputFormatter({this.onContentBlocked});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final violationType = ContentFilter.checkContent(newValue.text);
    
    if (violationType != null) {
      // Hacer vibrar el dispositivo
      HapticFeedback.lightImpact();
      
      // Notificar la violación si hay callback
      onContentBlocked?.call(violationType);
      
      // Devolver el valor anterior (bloquear el cambio)
      return oldValue;
    }
    
    return newValue;
  }
}

/// Mixin para facilitar el uso del filtro de contenido
mixin ContentFilterMixin<T extends StatefulWidget> on State<T> {
  void showContentFilterWarning(String violationType) {
    ContentFilter.showWarning(context, violationType);
  }

  /// Verifica contenido antes de enviar
  bool validateContentBeforeSend(String content) {
    final violationType = ContentFilter.checkContent(content);
    if (violationType != null) {
      showContentFilterWarning(violationType);
      return false;
    }
    return true;
  }
}

/// Widget que muestra información sobre las políticas de contenido
class ContentPolicyDialog extends StatelessWidget {
  const ContentPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.security, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Política de Contenido'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Para tu seguridad y privacidad, el chat tiene las siguientes restricciones:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            
            Text('❌ Contenido no permitido:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Números de teléfono y celular'),
            Text('• Direcciones de correo electrónico'),
            Text('• Usuarios de redes sociales (@handles)'),
            Text('• Enlaces a perfiles personales'),
            Text('• Solicitudes de información de contacto'),
            Text('• Información financiera o de identificación'),
            
            SizedBox(height: 16),
            
            Text('✅ Alternativas seguras:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Usar el sistema de mensajería interno'),
            Text('• Contactar través del marketplace de abogados'),
            Text('• Utilizar las funciones de la aplicación'),
            
            SizedBox(height: 16),
            
            Text(
              'Estas medidas protegen tu información personal y garantizan un entorno seguro para todos los usuarios.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}
