import 'package:flutter/material.dart';

class MobileLayoutHelper {
  // 📱 Breakpoints para diferentes tamaños de pantalla
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  
  // 🎯 Detectar si es móvil
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  // 📱 Detectar si es tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  // 🖥️ Detectar si es desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // 📏 Obtener padding horizontal responsivo
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 32.0;
    return 64.0;
  }
  
  // 📐 Obtener ancho máximo para contenido
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 600.0;
    return 800.0;
  }
  
  // 🎨 Obtener espaciado vertical
  static double getVerticalSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    return 20.0;
  }
  
  // 📱 Obtener altura de botón optimizada
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 52.0;
    return 48.0;
  }
  
  // 🔤 Obtener tamaño de fuente responsivo
  static double getFontSize(BuildContext context, String type) {
    final isMobileDevice = isMobile(context);
    
    switch (type) {
      case 'headline':
        return isMobileDevice ? 24.0 : 28.0;
      case 'title':
        return isMobileDevice ? 20.0 : 24.0;
      case 'body':
        return isMobileDevice ? 14.0 : 16.0;
      case 'caption':
        return isMobileDevice ? 12.0 : 14.0;
      default:
        return isMobileDevice ? 14.0 : 16.0;
    }
  }
}

// 📱 Widget responsivo personalizado
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    if (MobileLayoutHelper.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (MobileLayoutHelper.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// 📱 Container responsivo para móvil
class MobileContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  
  const MobileContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MobileLayoutHelper.getMaxContentWidth(context),
      ),
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: MobileLayoutHelper.getHorizontalPadding(context),
        vertical: MobileLayoutHelper.getVerticalSpacing(context),
      ),
      child: centerContent 
        ? Center(child: child)
        : child,
    );
  }
}

// 📱 AppBar optimizada para móvil
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  
  const MobileAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: MobileLayoutHelper.getFontSize(context, 'title'),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      elevation: 0,
      backgroundColor: const Color(0xFFBB8B30),
      foregroundColor: Colors.white,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// 📱 Botón optimizado para móvil
class MobileButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  
  const MobileButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MobileLayoutHelper.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFBB8B30),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading 
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: MobileLayoutHelper.getFontSize(context, 'body'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
