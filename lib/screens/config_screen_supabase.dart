import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_supabase.dart';

class ConfigScreenSupabase extends StatelessWidget {
  const ConfigScreenSupabase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFFDAA520),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFDAA520),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                children: [
                  Text(
                    authProvider.user?.email ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFDAA520)),
                    title: const Text('Perfil'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navegar a perfil
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xFFDAA520)),
                    title: const Text('Notificaciones'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navegar a notificaciones
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFFDAA520)),
                    title: const Text('Ayuda'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navegar a ayuda
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFFDAA520)),
                    title: const Text('Acerca de'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navegar a acerca de
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar Sesión'),
                          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Cerrar Sesión'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await authProvider.signOut();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
