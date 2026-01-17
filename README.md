# Logic Lex - Asistencia Legal

Una aplicación Flutter moderna para conectar clientes con abogados especializados, con dashboards completamente separados para cada tipo de usuario.

## � Arquitectura de Roles

### 👨‍💼 Dashboard del Cliente
- **Publicación de casos**: Interfaz para describir situaciones legales
- **Búsqueda de abogados**: Sistema avanzado de filtros por especialidad
- **Gestión de propuestas**: Recibir y evaluar ofertas de abogados
- **Chat con IA**: Asistencia jurídica inicial automatizada
- **Seguimiento de casos**: Estado y progreso de casos activos

### ⚖️ Dashboard del Abogado  
- **Marketplace de casos**: Explorar casos publicados por clientes
- **Gestión de clientes**: Panel de administración de casos activos
- **Sistema de propuestas**: Envío de ofertas profesionales
- **Calendario legal**: Gestión de citas y fechas importantes
- **Perfil profesional**: Especialidades, certificaciones y experiencia

## 🔐 Sistema de Autenticación

### Validación Estricta de Roles
```typescript
// Flujo de autenticación
User Authentication → Role Validation → Dashboard Routing

if (userType === 'abogado') {
  return LawyerDashboardScreen();
} else if (userType === 'cliente') {
  return ClientDashboardScreen();
}
```

### Características de Seguridad
- **Dashboards completamente separados**: Cero contaminación cruzada
- **Rutas únicas por rol**: Cada tipo de usuario tiene sus propias vistas
- **Validación en tiempo real**: Verificación continua del tipo de usuario
- **Setup automático**: Configuración inicial para usuarios nuevos

## 🎨 Características de Diseño

### ✨ Splash Screen Animado
- Ahora incluye un **video de carga** a pantalla completa (responsive) tomado del proyecto previo.
- Reproduce una sola vez y navega automáticamente según tu estado de autenticación (Auth → Email verificado → Home).
- Fallback seguro a splash estático si el video no está disponible o falla la inicialización.

#### Cómo configurar el video de carga

1. Copia el archivo de video desde tu proyecto anterior a:
  `C:\Users\juanc\OneDrive\Escritorio\Logic 1\video de carga` → `assets/videos/splash.mp4`
2. Verifica que en `pubspec.yaml` esté incluida la ruta `assets/videos/` y ejecuta:
  ```powershell
  flutter pub get
  ```
3. Ejecuta la app. Si el video se llama distinto, ajusta la ruta en `lib/screens/splash_screen.dart`:
  `VideoPlayerController.asset('assets/videos/splash.mp4')`

##### Extra para Web (evitar barras/loader azules)

Para que el video aparezca ANTES de que Flutter cargue (y ocultar el loader por defecto), copia también el archivo a:

- `web/videos/fondocarga.mp4`

El `web/index.html` ya está configurado para mostrar `web/videos/fondocarga.mp4` a pantalla completa y ocultarlo cuando Flutter renderiza su primer frame. Si usas otro nombre, actualiza la etiqueta `<source>` en `web/index.html`.

### 🎯 Material Design 3
- **Colores consistentes**: Azul (#3B82F6), Dorado (#BB8B30), Gris (#64748B)
- **Tipografía moderna**: Google Fonts (Poppins + Inter)
- **Componentes responsive**: Adaptables a diferentes tamaños de pantalla
- **Animaciones fluidas**: Transiciones suaves entre estados

## Características Funcionales

- ✅ **Separación completa de roles**: Dashboards únicos para abogados y clientes
- ✅ **Marketplace de casos**: Sistema tipo bolsa de empleo para casos legales
- ✅ **Gestión de propuestas**: Workflow completo cliente-abogado
- ✅ **Chat con IA**: Asistencia jurídica automatizada
- ✅ **Sistema de filtros**: Búsqueda avanzada por especialidad y ubicación
- ✅ **Firebase Integration**: Autenticación y base de datos en tiempo real
- ✅ **Provider State Management**: Gestión eficiente del estado de la app
- ✅ **Trámites Jurídicos**: Sistema para que estudiantes de derecho ayuden a clientes

## 🎓 Sistema de Trámites Jurídicos

### Descripción
Un sistema innovador que permite a estudiantes de derecho (séptimo semestre en adelante) ayudar a clientes con trámites legales menores bajo supervisión.

### Tipos de Trámites Disponibles

#### 📝 Borradores de Textos Jurídicos
- **Contratos**: Elaboración de borradores de contratos civiles y comerciales
- **Tutelas y Derechos de Petición**: Redacción de tutelas y derechos de petición
- **Poderes**: Elaboración de borradores de poderes

#### 📋 Trámites Jurídicos
- **Radicación de Documentos**: Radicación ante juzgados o entidades públicas
- **Solicitud de Certificados**: Gestión de solicitud de certificados legales

#### 💡 Conceptos Jurídicos
- **Conceptos sobre Situaciones Legales**: Conceptos respecto a derechos involucrados

### Flujo del Sistema

```typescript
// 1. Cliente crea solicitud
Cliente → Selecciona tipo de trámite → Describe necesidad → Publica

// 2. Estudiantes verificados ven solicitudes
Estudiante verificado → Ve trámites disponibles → Envía propuesta

// 3. Cliente evalúa y acepta
Cliente → Revisa propuestas → Acepta una → Estudiante asignado

// 4. Desarrollo y entrega
Estudiante → Desarrolla trámite → Envía entregables → Cliente revisa
```

### Restricciones Legales Importantes
> "Los estudiantes no podrán firmar poderes judiciales o actuar como apoderado en audiencias judiciales, como tampoco sustituir poder o actuar sin autorización escrita"

### Tablas de Base de Datos
- `legal_procedures`: Solicitudes de trámites
- `procedure_proposals`: Propuestas de estudiantes
- `procedure_messages`: Mensajes entre cliente y estudiante
- `procedure_deliverables`: Entregables del trámite
- `student_verifications`: Verificación de estudiantes

## Funcionalidades por Rol

### 👨‍💼 Cliente
- **Publicar casos** con descripción detallada
- **Recibir propuestas** de abogados interesados
- **Comparar perfiles** de abogados especializados
- **Chat directo** con profesionales seleccionados
- **Seguimiento de casos** activos y completados

### ⚖️ Abogado
- **Explorar marketplace** de casos disponibles
- **Enviar propuestas** profesionales con presupuestos
- **Gestionar clientes** activos y potenciales  
- **Mostrar especialidades** y certificaciones
- **Dashboard de métricas** de rendimiento profesional

## Estructura del Proyecto

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── screens/                  # Pantallas de la aplicación
│   ├── main_screen.dart      # Navegación principal
│   ├── home_screen.dart      # IA Chat (pantalla principal)
│   ├── lawyer_screen.dart    # Tu Abogado
│   └── processes_screen.dart # Procesos
├── widgets/                  # Widgets reutilizables
├── providers/                # Estado global con Provider
├── models/                   # Modelos de datos
├── services/                 # Servicios externos
└── utils/                    # Utilidades y constantes
```

## Instalación y Configuración

### Prerrequisitos

1. **Instalar Flutter SDK**
   - Descargar desde: https://flutter.dev/docs/get-started/install/windows
   - Agregar Flutter al PATH del sistema
   - Verificar instalación: `flutter doctor`

2. **Instalar Android Studio**
   - Descargar desde: https://developer.android.com/studio
   - Instalar Android SDK y herramientas

3. **Configurar emulador o dispositivo físico**

### Pasos para ejecutar el proyecto

1. Clonar o descargar este proyecto
2. Abrir terminal en la carpeta del proyecto
3. Ejecutar: `flutter pub get`
4. Ejecutar: `flutter run`

## Comandos Útiles

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Ejecutar tests
flutter test

# Generar APK para release
flutter build apk --release

# Generar App Bundle para Play Store
flutter build appbundle --release

# Verificar configuración
flutter doctor

# Limpiar proyecto
flutter clean
```

## Preparación para Play Store

### 1. Configurar signing key

Crear un keystore para firmar la aplicación:

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

### 2. Configurar build.gradle

Editar `android/app/build.gradle` para incluir la configuración de signing.

### 3. Actualizar AndroidManifest.xml

- Cambiar el nombre de la aplicación
- Configurar permisos necesarios
- Establecer icono de la aplicación

### 4. Generar App Bundle

```bash
flutter build appbundle --release
```

### 5. Preparar assets para Play Store

- Icono de la aplicación (512x512 px)
- Capturas de pantalla
- Descripción de la aplicación
- Política de privacidad

## Próximos Pasos

1. Personalizar la aplicación según tus necesidades
2. Agregar más pantallas y funcionalidades
3. Implementar autenticación si es necesario
4. Configurar analytics y crash reporting
5. Añadir tests más completos
6. Optimizar rendimiento

## Dependencias Principales

- **provider**: State management
- **http**: Peticiones HTTP
- **shared_preferences**: Almacenamiento local
- **image_picker**: Selección de imágenes
- **cached_network_image**: Cache de imágenes

## Soporte

Para más información sobre Flutter:
- [Documentación oficial](https://flutter.dev/docs)
- [Cookbook de Flutter](https://flutter.dev/docs/cookbook)
- [API reference](https://api.flutter.dev/)
