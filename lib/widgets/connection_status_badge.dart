import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

enum ConnectionStatus {
  online,
  away,
  offline,
}

class ConnectionStatusBadge extends StatefulWidget {
  final ConnectionStatus? initialStatus;

  const ConnectionStatusBadge({
    Key? key,
    this.initialStatus,
  }) : super(key: key);

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge> {
  late ConnectionStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus ?? ConnectionStatus.online;
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return Colors.green;
      case ConnectionStatus.away:
        return Colors.orange;
      case ConnectionStatus.offline:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return 'En línea';
      case ConnectionStatus.away:
        return 'Ausente';
      case ConnectionStatus.offline:
        return 'Desconectado';
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case ConnectionStatus.online:
        return Icons.circle;
      case ConnectionStatus.away:
        return Icons.access_time;
      case ConnectionStatus.offline:
        return Icons.circle_outlined;
    }
  }

  void _showStatusMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<ConnectionStatus>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem<ConnectionStatus>(
          value: ConnectionStatus.online,
          child: Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 16),
              const SizedBox(width: 12),
              Text(
                'En línea',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<ConnectionStatus>(
          value: ConnectionStatus.away,
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange, size: 16),
              const SizedBox(width: 12),
              Text(
                'Ausente',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<ConnectionStatus>(
          value: ConnectionStatus.offline,
          child: Row(
            children: [
              Icon(Icons.circle_outlined, color: Colors.red, size: 16),
              const SizedBox(width: 12),
              Text(
                'Desconectado',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null && mounted) {
        setState(() {
          _currentStatus = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showStatusMenu,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 12,
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.onPrimary.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
