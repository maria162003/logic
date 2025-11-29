import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _initFailed = false;
  bool _navigated = false;
  static const int _maxSplashMs = 1200; // reducir espera para arranque rápido

  @override
  void initState() {
    super.initState();
    _setupVideoAndNavigate();
  }

  Future<void> _setupVideoAndNavigate() async {
    // En Web, el video de carga se muestra como overlay en web/index.html.
    // Evitamos reproducir otro video dentro de la app para no duplicar y navegamos rápido.
    if (kIsWeb) {
      Future.delayed(const Duration(milliseconds: _maxSplashMs), () {
        if (!_navigated) _navigateAccordingToAuth();
      });
      return;
    }

    // Intenta cargar el video del proyecto anterior como asset.
    // Por defecto esperamos un archivo en: assets/videos/splash.mp4
  // Usar el video provisto por el usuario en la carpeta "video de carga".
  // Si prefieres moverlo a assets/videos/splash.mp4, avísame y ajusto.
  _controller = VideoPlayerController.asset('video de carga/fondocarga.mp4');

    // Fallback de seguridad: aunque el video falle, navegamos rápido (~1.2s)
    Future.delayed(const Duration(milliseconds: _maxSplashMs), () {
      if (!_navigated) _navigateAccordingToAuth();
    });

    try {
      await _controller.initialize();
      if (!mounted) return;

      // Configuración del video
      _controller.setLooping(false);
      _controller.setVolume(0); // Evitar sonido inesperado

      setState(() {
        _initialized = true;
      });

      // Reproducir y escuchar fin
      _controller.play();
      _controller.addListener(_onVideoProgress);
    } catch (e) {
      // Si falla la inicialización, usa la pantalla estática y navega por timeout
      setState(() {
        _initFailed = true;
      });
    }
  }

  void _onVideoProgress() {
    if (!_controller.value.isInitialized) return;
    final value = _controller.value;
    // Navega cuando termine el video
    if (!_navigated && value.position >= value.duration && !value.isPlaying) {
      _navigateAccordingToAuth();
    }
  }

  void _navigateAccordingToAuth() {
    if (!mounted) return;
    _navigated = true;

    try {
      final currentUser = AuthService.currentUser;

      if (currentUser != null) {
        if (currentUser.emailConfirmedAt != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/email-verification');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    } catch (e) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.removeListener(_onVideoProgress);
      _controller.dispose();
    } else {
      // En caso de fallo también intentamos liberar
      try { _controller.dispose(); } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si el video no se pudo iniciar, usa el diseño anterior como respaldo
    if (_initFailed) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
              image: AssetImage('images_logo/imagen_fondo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [AppColors.goldGlow, AppColors.goldShadow],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Logo-Completo-Logic-IA-Dorado.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Logic Lex',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    // Video a pantalla completa, responsivo
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized)
            LayoutBuilder(
              builder: (context, constraints) {
                final size = _controller.value.size;
                // Envuelve para cubrir toda la pantalla sin deformar
                return FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(_controller),
                  ),
                );
              },
            )
          else
            // Mientras inicializa, muestra un fondo y loader
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),

          // Overlay sutil opcional (gradiente) para dispositivos con notch
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black12],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
