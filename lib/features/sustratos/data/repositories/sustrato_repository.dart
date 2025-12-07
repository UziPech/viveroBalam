import 'package:hive/hive.dart';
import '../../domain/entities/sustrato.dart';

/// Repositorio para operaciones CRUD de sustratos
class SustratoRepository {
  final Box<Sustrato> _box;

  SustratoRepository(this._box);

  // ==================== CREATE ====================
  
  Future<void> saveSustrato(Sustrato sustrato) async {
    await _box.add(sustrato);
  }

  // ==================== READ ====================
  
  List<Sustrato> getAllSustratos() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Sustrato? getSustratoByKey(dynamic key) {
    return _box.get(key);
  }

  Stream<List<Sustrato>> watchAllSustratos() async* {
    yield getAllSustratos();
    await for (final _ in _box.watch()) {
      yield getAllSustratos();
    }
  }

  // ==================== UPDATE ====================
  
  Future<void> updateSustrato(Sustrato sustrato) async {
    if (sustrato.key != null) {
      await _box.put(sustrato.key, sustrato);
    }
  }

  /// Actualiza la cantidad de un sustrato
  Future<void> updateCantidad(dynamic key, int nuevaCantidad) async {
    final sustrato = _box.get(key);
    if (sustrato != null) {
      sustrato.cantidad = nuevaCantidad;
      await _box.put(key, sustrato);
    }
  }

  // ==================== DELETE ====================
  
  Future<void> deleteSustrato(Sustrato sustrato) async {
    await _box.delete(sustrato.key);
  }

  // ==================== STATS ====================
  
  int get totalSustratos => _box.length;

  double get valorTotal => _box.values.fold(0, (sum, s) => sum + s.precio);

  int get bajosEnStock => _box.values.where((s) => s.cantidad < 5).length;
}
