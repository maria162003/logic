import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'lawyer_screen.dart';
import 'processes_screen.dart';
import '../providers/app_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LawyerScreen(),
    const ProcessesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos de ejemplo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadMockData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF6B6B6B), // Cambiar a gris
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBottomNavItem(
                    icon: Icons.chat_bubble,
                    label: 'IA Chat',
                    index: 0,
                  ),
                ),
                Expanded(
                  child: _buildBottomNavItem(
                    icon: Icons.account_circle,
                    label: 'Tu Abogado',
                    index: 1,
                  ),
                ),
                Expanded(
                  child: _buildBottomNavItem(
                    icon: Icons.description,
                    label: 'Procesos',
                    index: 2,
                    notificationCount: appState.unreadNotifications,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    int notificationCount = 0,
  }) {
    final bool isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFF6B6B6B) : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        // Badge de notificaciones
        if (notificationCount > 0)
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  notificationCount > 9 ? '9+' : notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}