import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FAQ {
  final String id;
  final String category;
  final String question;
  final String answer;
  final int orderIndex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQ({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.orderIndex,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer': answer,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class FAQProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<FAQ> _faqs = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  List<FAQ> get faqs => _faqs;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<FAQ> get filteredFAQs {
    List<FAQ> filtered = _faqs.where((faq) => faq.isActive).toList();
    
    // Filtrar por categoría si está seleccionada
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where((faq) => faq.category == _selectedCategory).toList();
    }
    
    // Filtrar por búsqueda si hay texto
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((faq) {
        return faq.question.toLowerCase().contains(query) ||
               faq.answer.toLowerCase().contains(query) ||
               faq.category.toLowerCase().contains(query);
      }).toList();
    }
    
    // Ordenar por order_index
    filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    
    return filtered;
  }

  Future<void> loadFAQs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('faqs')
          .select('*')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      _faqs = (response as List)
          .map((json) => FAQ.fromJson(json))
          .toList();

      // Extraer categorías únicas
      _categories = _faqs
          .map((faq) => faq.category)
          .toSet()
          .toList()
        ..sort();

      _error = null;
    } catch (e) {
      _error = 'Error al cargar las preguntas frecuentes: ${e.toString()}';
      print('Error loading FAQs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  Future<void> createFAQ(FAQ faq) async {
    try {
      await _supabase.from('faqs').insert(faq.toJson());
      await loadFAQs(); // Recargar la lista
    } catch (e) {
      _error = 'Error al crear la FAQ: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateFAQ(FAQ faq) async {
    try {
      await _supabase
          .from('faqs')
          .update(faq.toJson())
          .eq('id', faq.id);
      await loadFAQs(); // Recargar la lista
    } catch (e) {
      _error = 'Error al actualizar la FAQ: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteFAQ(String id) async {
    try {
      await _supabase
          .from('faqs')
          .update({'is_active': false})
          .eq('id', id);
      await loadFAQs(); // Recargar la lista
    } catch (e) {
      _error = 'Error al eliminar la FAQ: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Método para obtener FAQs por categoría específica
  List<FAQ> getFAQsByCategory(String category) {
    return _faqs
        .where((faq) => faq.category == category && faq.isActive)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  // Método para buscar FAQs por texto
  List<FAQ> searchFAQs(String query) {
    final searchQuery = query.toLowerCase();
    return _faqs
        .where((faq) => 
            faq.isActive && (
            faq.question.toLowerCase().contains(searchQuery) ||
            faq.answer.toLowerCase().contains(searchQuery)))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }
}