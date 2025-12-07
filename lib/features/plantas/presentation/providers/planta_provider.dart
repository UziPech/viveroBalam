import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/planta_repository.dart';
import '../../domain/entities/planta.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/sync_service.dart';

// ==================== PROVIDERS DE INFRAESTRUCTURA ====================

/// Provider de la caja de Hive para plantas (debe inicializarse en main.dart)
final hiveBoxPlantasProvider = Provider<Box<Planta>>((ref) {
  return Hive.box<Planta>('plantas');
});

/// Provider del repositorio de plantas
final plantaRepoProvider = Provider<PlantaRepository>((ref) {
  final box = ref.watch(hiveBoxPlantasProvider);
  return PlantaRepository(box);
});

/// Provider del servicio de imágenes
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

/// Provider del servicio de sincronización
final syncServiceProvider = Provider<SyncService>((ref) {
  final box = ref.watch(hiveBoxPlantasProvider);
  return SyncService(box);
});

// ==================== PROVIDERS DE DATOS ====================

/// Stream Provider: Lista de plantas en tiempo real
final plantasStreamProvider = StreamProvider<List<Planta>>((ref) {
  final repo = ref.watch(plantaRepoProvider);
  return repo.watchAllPlantas();
});

/// Provider de estadísticas
final plantasStatsProvider = Provider<PlantaStats>((ref) {
  final plantasAsync = ref.watch(plantasStreamProvider);
  
  return plantasAsync.when(
    data: (plantas) => PlantaStats(
      total: plantas.length,
      categorias: _countByCategoria(plantas),
    ),
    loading: () => PlantaStats.empty(),
    error: (_, __) => PlantaStats.empty(),
  );
});

/// Provider de categorías únicas
final categoriasProvider = Provider<List<String>>((ref) {
  final plantasAsync = ref.watch(plantasStreamProvider);
  
  return plantasAsync.when(
    data: (plantas) {
      final categorias = plantas.map((p) => p.categoria).toSet().toList();
      categorias.sort();
      return categorias;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ==================== HELPERS ====================

Map<String, int> _countByCategoria(List<Planta> plantas) {
  final counts = <String, int>{};
  for (final planta in plantas) {
    counts[planta.categoria] = (counts[planta.categoria] ?? 0) + 1;
  }
  return counts;
}

/// Clase para estadísticas de plantas
class PlantaStats {
  final int total;
  final Map<String, int> categorias;

  PlantaStats({required this.total, required this.categorias});

  factory PlantaStats.empty() => PlantaStats(total: 0, categorias: {});

  /// Categorías predefinidas para el dropdown
  static const List<String> categoriasPredefinidas = [
    'Suculenta',
    'Floral',
    'Árbol',
    'Frutal',
    'Maceta',
    'Sombra',
    'Ornamental',
    'Cactus',
  ];
}
