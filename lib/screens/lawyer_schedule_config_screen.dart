import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_supabase.dart';
import '../services/supabase_service.dart';
import '../utils/app_colors.dart';

class LawyerScheduleConfigScreen extends StatefulWidget {
  const LawyerScheduleConfigScreen({super.key});

  @override
  State<LawyerScheduleConfigScreen> createState() => _LawyerScheduleConfigScreenState();
}

class _LawyerScheduleConfigScreenState extends State<LawyerScheduleConfigScreen> {
  // Horarios por día de la semana
  Map<String, Map<String, dynamic>> _weeklySchedule = {
    'Lunes': {'enabled': true, 'start': '09:00', 'end': '18:00'},
    'Martes': {'enabled': true, 'start': '09:00', 'end': '18:00'},
    'Miércoles': {'enabled': true, 'start': '09:00', 'end': '18:00'},
    'Jueves': {'enabled': true, 'start': '09:00', 'end': '18:00'},
    'Viernes': {'enabled': true, 'start': '09:00', 'end': '17:00'},
    'Sábado': {'enabled': false, 'start': '09:00', 'end': '13:00'},
    'Domingo': {'enabled': false, 'start': '09:00', 'end': '13:00'},
  };

  // Configuraciones generales
  int _appointmentDuration = 60; // minutos
  int _bufferTime = 15; // minutos entre citas
  bool _allowWeekendConsultations = false;
  bool _allowEmergencyContacts = true;
  String _timezone = 'America/Bogota';

  // Excepciones y días especiales
  List<Map<String, dynamic>> _exceptions = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId != null) {
        // Verificar si es estudiante
        if (authProvider.isStudent) {
          // Para estudiantes, configurar horarios básicos por defecto
          setState(() {
            _weeklySchedule = {
              'Lunes': {'start': '09:00', 'end': '17:00', 'enabled': true},
              'Martes': {'start': '09:00', 'end': '17:00', 'enabled': true},
              'Miércoles': {'start': '09:00', 'end': '17:00', 'enabled': true},
              'Jueves': {'start': '09:00', 'end': '17:00', 'enabled': true},
              'Viernes': {'start': '09:00', 'end': '17:00', 'enabled': true},
              'Sábado': {'start': '09:00', 'end': '13:00', 'enabled': false},
              'Domingo': {'start': '09:00', 'end': '13:00', 'enabled': false},
            };
            _isLoading = false;
          });
          return;
        }
        
        final lawyerProfile = await SupabaseService.getLawyerProfile(authProvider.userId!);
        
        if (lawyerProfile != null && mounted) {
          setState(() {
            // Cargar horarios semanales si existen
            if (lawyerProfile['weekly_schedule'] != null) {
              final loadedSchedule = Map<String, Map<String, dynamic>>.from(
                lawyerProfile['weekly_schedule']
              );
              
              // Asegurar que todos los días tengan la clave 'enabled' con valor booleano
              loadedSchedule.forEach((day, schedule) {
                schedule['enabled'] = schedule['enabled'] ?? true;
                schedule['start'] = schedule['start'] ?? '09:00';
                schedule['end'] = schedule['end'] ?? '18:00';
              });
              
              _weeklySchedule = loadedSchedule;
            }
            
            // Cargar configuraciones
            _appointmentDuration = lawyerProfile['appointment_duration'] ?? 60;
            _bufferTime = lawyerProfile['buffer_time'] ?? 15;
            _allowWeekendConsultations = lawyerProfile['allow_weekend_consultations'] ?? false;
            _allowEmergencyContacts = lawyerProfile['allow_emergency_contacts'] ?? true;
            _timezone = lawyerProfile['timezone'] ?? 'America/Bogota';
            
            // Cargar excepciones si existen
            if (lawyerProfile['exceptions'] != null) {
              _exceptions = List<Map<String, dynamic>>.from(lawyerProfile['exceptions']);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar horarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Horarios de Disponibilidad',
          style: GoogleFonts.poppins(
            color: AppColors.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveSchedule,
            child: Text(
              'Guardar',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horarios semanales
            _buildSectionHeader('Horarios Semanales', Icons.schedule),
            _buildWeeklySchedule(),
            
            const SizedBox(height: 30),
            
            // Configuraciones generales
            _buildSectionHeader('Configuraciones Generales', Icons.settings),
            _buildGeneralSettings(),
            
            const SizedBox(height: 30),
            
            // Excepciones y días especiales
            _buildSectionHeader('Excepciones y Días Especiales', Icons.event_busy),
            _buildExceptions(),
            
            const SizedBox(height: 30),
            
            // Vista previa del calendario
            _buildSectionHeader('Vista Previa', Icons.calendar_month),
            _buildSchedulePreview(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: _weeklySchedule.entries.map((entry) {
          final day = entry.key;
          final schedule = entry.value;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Día de la semana
                SizedBox(
                  width: 80,
                  child: Text(
                    day,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Switch habilitado/deshabilitado
                Switch(
                  value: schedule['enabled'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _weeklySchedule[day]!['enabled'] = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                
                const SizedBox(width: 16),
                
                // Horarios si está habilitado
                if (schedule['enabled'])
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeSelector(
                            'Inicio',
                            schedule['start'],
                            (time) {
                              setState(() {
                                _weeklySchedule[day]!['start'] = time;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'a',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTimeSelector(
                            'Fin',
                            schedule['end'],
                            (time) {
                              setState(() {
                                _weeklySchedule[day]!['end'] = time;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'No disponible',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSelector(String label, String time, Function(String) onChanged) {
    return GestureDetector(
      onTap: () => _selectTime(context, time, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          time,
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Duración de citas
          _buildSliderSetting(
            'Duración de Citas',
            '$_appointmentDuration minutos',
            _appointmentDuration.toDouble(),
            30.0,
            120.0,
            (value) {
              setState(() {
                _appointmentDuration = value.round();
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Tiempo de buffer
          _buildSliderSetting(
            'Tiempo entre Citas',
            '$_bufferTime minutos',
            _bufferTime.toDouble(),
            0.0,
            60.0,
            (value) {
              setState(() {
                _bufferTime = value.round();
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Configuraciones adicionales
          SwitchListTile(
            title: Text(
              'Consultas de Fin de Semana',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            subtitle: Text(
              'Permitir citas los sábados y domingos',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            value: _allowWeekendConsultations,
            onChanged: (value) {
              setState(() {
                _allowWeekendConsultations = value;
              });
            },
            activeColor: AppColors.primary,
            tileColor: Colors.transparent,
          ),
          
          SwitchListTile(
            title: Text(
              'Contactos de Emergencia',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            subtitle: Text(
              'Permitir contacto fuera del horario laboral',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            value: _allowEmergencyContacts,
            onChanged: (value) {
              setState(() {
                _allowEmergencyContacts = value;
              });
            },
            activeColor: AppColors.primary,
            tileColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String value,
    double currentValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: ((max - min) / 15).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildExceptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Días Especiales y Excepciones:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: _addException,
                icon: Icon(Icons.add, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_exceptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay excepciones configuradas',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_exceptions.asMap().entries.map((entry) {
              final index = entry.key;
              final exception = entry.value;
              return _buildExceptionItem(exception, index);
            }).toList()),
        ],
      ),
    );
  }

  Widget _buildExceptionItem(Map<String, dynamic> exception, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            exception['type'] == 'vacation' ? Icons.beach_access : Icons.event_busy,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exception['title'] ?? 'Sin título',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${exception['startDate']} - ${exception['endDate']}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeException(index),
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Resumen de Disponibilidad',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...(_weeklySchedule.entries.where((e) => e.value['enabled']).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${entry.value['start']} - ${entry.value['end']}',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Citas de $_appointmentDuration min con $_bufferTime min de separación',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectTime(BuildContext context, String currentTime, Function(String) onChanged) async {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(timeString);
    }
  }

  void _addException() {
    showDialog(
      context: context,
      builder: (context) => _ExceptionDialog(
        onAdd: (exception) {
          setState(() {
            _exceptions.add(exception);
          });
        },
      ),
    );
  }

  void _removeException(int index) {
    setState(() {
      _exceptions.removeAt(index);
    });
  }

  void _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await SupabaseService.updateLawyerSchedule(
        lawyerId: authProvider.userId!,
        weeklySchedule: _weeklySchedule,
        appointmentDuration: _appointmentDuration,
        bufferTime: _bufferTime,
        allowWeekendConsultations: _allowWeekendConsultations,
        allowEmergencyContacts: _allowEmergencyContacts,
        timezone: _timezone,
        exceptions: _exceptions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Horarios guardados exitosamente',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar horarios: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _ExceptionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _ExceptionDialog({required this.onAdd});

  @override
  State<_ExceptionDialog> createState() => _ExceptionDialogState();
}

class _ExceptionDialogState extends State<_ExceptionDialog> {
  final _titleController = TextEditingController();
  String _type = 'vacation';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Agregar Excepción',
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Título',
              labelStyle: GoogleFonts.poppins(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Tipo',
              labelStyle: GoogleFonts.poppins(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            dropdownColor: AppColors.surface,
            items: [
              DropdownMenuItem(
                value: 'vacation',
                child: Text('Vacaciones', style: GoogleFonts.poppins(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'unavailable',
                child: Text('No disponible', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _type = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onAdd({
                'title': _titleController.text,
                'type': _type,
                'startDate': '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                'endDate': '${_endDate.day}/${_endDate.month}/${_endDate.year}',
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: Text('Agregar', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}