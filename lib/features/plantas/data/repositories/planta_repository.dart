import 'package:hive/hive.dart';
import '../../domain/entities/planta.dart';

/// Repositorio para operaciones CRUD de plantas
class PlantaRepository {
  final Box<Planta> _box;

  PlantaRepository(this._box);

  // ==================== CREATE ====================
  
  /// Guarda una nueva planta
  Future<void> savePlanta(Planta planta) async {
    await _box.add(planta);
  }

  // ==================== READ ====================
  
  /// Obtiene todas las plantas ordenadas por fecha (más recientes primero)
  List<Planta> getAllPlantas() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtiene una planta por su key de Hive
  Planta? getPlantaByKey(dynamic key) {
    return _box.get(key);
  }

  /// Stream para escuchar cambios en tiempo real
  Stream<List<Planta>> watchAllPlantas() async* {
    yield getAllPlantas();
    await for (final _ in _box.watch()) {
      yield getAllPlantas();
    }
  }

  // ==================== UPDATE ====================
  
  /// Actualiza una planta existente
  Future<void> updatePlanta(Planta planta) async {
    if (planta.key != null) {
      await _box.put(planta.key, planta);
    }
  }

  // ==================== DELETE ====================
  
  /// Elimina una planta
  Future<void> deletePlanta(Planta planta) async {
    await _box.delete(planta.key);
  }

  // ==================== QUERIES ====================
  
  /// Filtra plantas por categoría
  List<Planta> getPlantasByCategoria(String categoria) {
    return _box.values
        .where((p) => p.categoria.toLowerCase() == categoria.toLowerCase())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Busca plantas por nombre
  List<Planta> searchPlantas(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((p) => p.nombre.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtiene todas las categorías únicas
  List<String> getAllCategorias() {
    return _box.values
        .map((p) => p.categoria)
        .toSet()
        .toList()
      ..sort();
  }

  /// Cuenta total de plantas
  int get totalPlantas => _box.length;

  /// Cuenta plantas por categoría
  Map<String, int> getCountByCategoria() {
    final counts = <String, int>{};
    for (final planta in _box.values) {
      counts[planta.categoria] = (counts[planta.categoria] ?? 0) + 1;
    }
    return counts;
  }
}
