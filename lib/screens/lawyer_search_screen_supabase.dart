import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class LawyerSearchScreenSupabase extends StatefulWidget {
  const LawyerSearchScreenSupabase({super.key});

  @override
  State<LawyerSearchScreenSupabase> createState() => _LawyerSearchScreenSupabaseState();
}

class _LawyerSearchScreenSupabaseState extends State<LawyerSearchScreenSupabase> {
  List<Map<String, dynamic>> lawyers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLawyers();
  }

  Future<void> _loadLawyers() async {
    try {
      final result = await SupabaseService.searchLawyers();
      setState(() {
        lawyers = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar abogados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar Abogados',
          style: TextStyle(
            color: Colors.black, // Texto negro para contraste
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFDAA520),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black, // Ícono negro para que se vea
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100], // Fondo gris claro
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lawyers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron abogados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600], // Texto gris oscuro visible
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Intenta ajustar tus criterios de búsqueda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: lawyers.length,
                    itemBuilder: (context, index) {
                      final lawyer = lawyers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFDAA520),
                            radius: 25,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            lawyer['full_name'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Texto negro visible
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              lawyer['specializations']?.join(', ') ?? 'Sin especialización',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600], // Texto gris oscuro visible
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            // TODO: Navegar a perfil del abogado
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Perfil de ${lawyer['full_name']}'),
                                backgroundColor: const Color(0xFFDAA520),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
