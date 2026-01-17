# Logic Lex - Copilot Instructions

## Proyecto
Aplicación Flutter para servicios legales con Supabase como backend.

## Estructura del Proyecto

### Roles de Usuario
- **Cliente**: Publica casos legales, solicita trámites jurídicos, recibe propuestas
- **Abogado**: Ve casos disponibles, envía propuestas, gestiona clientes
- **Estudiante**: Ve trámites jurídicos, envía propuestas para desarrollar documentos

### Base de Datos (Supabase)
- `user_profiles`: Perfiles de usuarios
- `legal_cases`: Casos legales publicados
- `case_proposals`: Propuestas de abogados
- `lawyer_profiles`: Perfiles de abogados
- `legal_procedures`: Trámites jurídicos para estudiantes
- `procedure_proposals`: Propuestas de estudiantes
- `procedure_messages`: Mensajes de trámites
- `procedure_deliverables`: Entregables de trámites
- `student_verifications`: Verificación de estudiantes

### Servicios Principales
- `supabase_connection_service.dart`: Conexión a Supabase
- `case_service.dart`: Gestión de casos legales
- `legal_procedures_service.dart`: Gestión de trámites jurídicos
- `ai_chat_service.dart`: Chat con IA legal

### Pantallas Clave
- `home_screen_supabase.dart`: Dashboard del cliente
- `lawyer_dashboard_screen.dart`: Dashboard del abogado
- `tramites_juridicos_screen.dart`: Crear trámites jurídicos
- `mis_tramites_screen.dart`: Ver trámites del cliente
- `my_cases_screen_supabase.dart`: Ver casos del cliente

## Comandos
- `flutter run -d chrome`: Ejecutar en web
- `flutter run`: Ejecutar en dispositivo/emulador
- `flutter pub get`: Instalar dependencias

## Estado del Proyecto
✅ Sistema de casos legales completo
✅ Sistema de propuestas de abogados
✅ Chat con IA legal
✅ Sistema de trámites jurídicos para estudiantes
✅ Formularios dinámicos por tipo de derecho
