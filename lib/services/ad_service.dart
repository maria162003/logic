import 'dart:math';

/// Servicio para gestión de anuncios publicitarios en la app
/// Se muestran durante el tiempo de espera de respuestas de IA (~10 segundos)
class AdService {
  static final Random _random = Random();

  /// Lista de anuncios disponibles
  /// En producción, estos vendrían de un backend o servicio de ads (Google AdMob, etc.)
  static final List<AdData> _ads = [
    AdData(
      id: 'ad_001',
      title: '¡Protege tu negocio!',
      description: 'Seguros empresariales desde \$99.000/mes',
      imageUrl: 'assets/images/ads/seguro_empresarial.png',
      ctaText: 'Más información',
      advertiser: 'Seguros ABC',
      type: AdType.banner,
      category: AdCategory.insurance,
    ),
    AdData(
      id: 'ad_002',
      title: 'Notaría Express',
      description: 'Autenticación de documentos en 24 horas',
      imageUrl: 'assets/images/ads/notaria.png',
      ctaText: 'Agendar cita',
      advertiser: 'Notaría 25',
      type: AdType.banner,
      category: AdCategory.legalServices,
    ),
    AdData(
      id: 'ad_003',
      title: 'Consulta Legal Premium',
      description: '50% de descuento en tu primera consulta',
      imageUrl: 'assets/images/ads/consulta_legal.png',
      ctaText: 'Ver oferta',
      advertiser: 'Logic Lex Premium',
      type: AdType.banner,
      category: AdCategory.legalServices,
    ),
    AdData(
      id: 'ad_004',
      title: 'Gestoría de Trámites',
      description: 'Nosotros hacemos tus trámites legales',
      imageUrl: 'assets/images/ads/gestoria.png',
      ctaText: 'Cotizar',
      advertiser: 'TrámitesYA',
      type: AdType.banner,
      category: AdCategory.legalServices,
    ),
    AdData(
      id: 'ad_005',
      title: 'Crédito para tu empresa',
      description: 'Hasta \$50.000.000 sin codeudor',
      imageUrl: 'assets/images/ads/credito.png',
      ctaText: 'Solicitar',
      advertiser: 'Banco Emprendedor',
      type: AdType.banner,
      category: AdCategory.financial,
    ),
  ];

  /// Obtener un anuncio aleatorio
  static AdData getRandomAd() {
    return _ads[_random.nextInt(_ads.length)];
  }

  /// Obtener un anuncio por categoría
  static AdData getAdByCategory(AdCategory category) {
    final categoryAds = _ads.where((ad) => ad.category == category).toList();
    if (categoryAds.isEmpty) return getRandomAd();
    return categoryAds[_random.nextInt(categoryAds.length)];
  }

  /// Registrar impresión de anuncio (para analytics)
  static Future<void> trackImpression(String adId) async {
    // TODO: Enviar a analytics/backend
    print('📊 Ad impression tracked: $adId');
  }

  /// Registrar clic en anuncio (para analytics)
  static Future<void> trackClick(String adId) async {
    // TODO: Enviar a analytics/backend
    print('🖱️ Ad click tracked: $adId');
  }

  /// Duración máxima del anuncio en segundos
  static const int maxAdDurationSeconds = 10;

  /// Duración mínima del anuncio en segundos (para garantizar visualización)
  static const int minAdDurationSeconds = 3;
}

/// Modelo de datos para un anuncio
class AdData {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String ctaText;
  final String advertiser;
  final AdType type;
  final AdCategory category;
  final String? targetUrl;

  const AdData({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ctaText,
    required this.advertiser,
    required this.type,
    required this.category,
    this.targetUrl,
  });
}

/// Tipos de anuncio
enum AdType {
  banner,
  interstitial,
  video,
}

/// Categorías de anuncios (para targeting)
enum AdCategory {
  legalServices,
  insurance,
  financial,
  education,
  general,
}
