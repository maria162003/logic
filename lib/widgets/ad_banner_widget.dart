import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ad_service.dart';
import '../utils/app_colors.dart';

/// Widget que muestra un anuncio publicitario durante la carga
/// Se muestra mientras la IA genera una respuesta (máx 10 segundos)
class AdBannerWidget extends StatefulWidget {
  final VoidCallback? onAdComplete;
  final VoidCallback? onAdSkip;
  final bool showSkipButton;
  final int minDisplaySeconds;

  const AdBannerWidget({
    super.key,
    this.onAdComplete,
    this.onAdSkip,
    this.showSkipButton = true,
    this.minDisplaySeconds = 3,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget>
    with SingleTickerProviderStateMixin {
  late AdData _currentAd;
  late AnimationController _progressController;
  Timer? _adTimer;
  int _remainingSeconds = AdService.maxAdDurationSeconds;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _currentAd = AdService.getRandomAd();
    AdService.trackImpression(_currentAd.id);

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: AdService.maxAdDurationSeconds),
    )..forward();

    _startAdTimer();
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= (AdService.maxAdDurationSeconds - widget.minDisplaySeconds)) {
            _canSkip = true;
          }
          if (_remainingSeconds <= 0) {
            timer.cancel();
            widget.onAdComplete?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _handleAdClick() {
    AdService.trackClick(_currentAd.id);
    // TODO: Abrir URL del anuncio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo ${_currentAd.advertiser}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSkip() {
    if (_canSkip) {
      _adTimer?.cancel();
      widget.onAdSkip?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.amber.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Contenido del anuncio
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleAdClick,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header con badge de "Publicidad"
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Publicidad',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Contador de tiempo
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_remainingSeconds}s',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Contenido principal
                      Row(
                        children: [
                          // Icono/Imagen del anuncio
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForCategory(_currentAd.category),
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Texto
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentAd.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentAd.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAd.advertiser,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Botón CTA
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _currentAd.ctaText,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Barra de progreso
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 3,
                  );
                },
              ),
            ),
            
            // Botón de cerrar/saltar
            if (widget.showSkipButton)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedOpacity(
                  opacity: _canSkip ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _canSkip ? _handleSkip : null,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: _canSkip ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(AdCategory category) {
    switch (category) {
      case AdCategory.legalServices:
        return Icons.gavel;
      case AdCategory.insurance:
        return Icons.security;
      case AdCategory.financial:
        return Icons.account_balance;
      case AdCategory.education:
        return Icons.school;
      case AdCategory.general:
        return Icons.campaign;
    }
  }
}
