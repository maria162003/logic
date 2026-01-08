import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://zohufwabzguzmqxkptqx.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvaHVmd2Fiemd1em1xeGtwdHF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2NTk5MDEsImV4cCI6MjA3NDIzNTkwMX0.Xro2gFDe0GXDM1iYdpbyDH6F9XHHSR-PD8w6o-L32cs';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: true, // Cambiar a false en producción
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}
