import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_wrapper_supabase.dart';
import 'screens/authentication_screen_supabase.dart';
import 'screens/login_screen_supabase.dart';
import 'screens/register_screen_supabase.dart';
import 'screens/email_verification_screen.dart';
import 'screens/registration_success_screen.dart';
import 'screens/create_demo_user_screen.dart';
import 'providers/auth_provider_supabase.dart';
import 'providers/marketplace_provider.dart';
import 'providers/user_config_provider.dart';
import 'providers/faq_provider.dart';
import 'providers/chat_provider.dart';
import 'utils/app_theme.dart';
import 'screens/test_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: 'assets/env.json');
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar servicio de notificaciones
  await NotificationService.initialize();
  
  runApp(const LogicApp());
}

class LogicApp extends StatelessWidget {
  const LogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (context) => UserConfigProvider()),
        ChangeNotifierProvider(create: (context) => FAQProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'LogicLex - Asistencia Legal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés
        ],
        locale: const Locale('es', 'ES'),
        home: const SplashScreen(),
        routes: {
          // Ruta opcional de prueba rápida del chat
          '/test-chat': (context) => const TestChatScreen(),
          // Ruta temporal para crear usuario demo
          '/create-demo': (context) => const CreateDemoUserScreen(),
          '/auth': (context) => const AuthenticationScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/registration-success': (context) => const RegistrationSuccessScreen(),
          '/home': (context) => const AuthWrapper(),
          '/email-verification': (context) => const EmailVerificationScreen(),
        },
      ),
    );
  }
}

