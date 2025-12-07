import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/sustrato_repository.dart';
import '../../domain/entities/sustrato.dart';
import '../../../../core/services/image_service.dart';

// ==================== PROVIDERS DE INFRAESTRUCTURA ====================

final hiveBoxSustratosProvider = Provider<Box<Sustrato>>((ref) {
  return Hive.box<Sustrato>('sustratos');
});

final sustratoRepoProvider = Provider<SustratoRepository>((ref) {
  final box = ref.watch(hiveBoxSustratosProvider);
  return SustratoRepository(box);
});

final sustratoImageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

// ==================== PROVIDERS DE DATOS ====================

final sustratosStreamProvider = StreamProvider<List<Sustrato>>((ref) {
  final repo = ref.watch(sustratoRepoProvider);
  return repo.watchAllSustratos();
});

/// Estadísticas de sustratos
final sustratosStatsProvider = Provider<SustratoStats>((ref) {
  final sustratosAsync = ref.watch(sustratosStreamProvider);
  
  return sustratosAsync.when(
    data: (sustratos) => SustratoStats(
      total: sustratos.length,
      valorTotal: sustratos.fold(0, (sum, s) => sum + s.precio),
      bajosEnStock: sustratos.where((s) => s.cantidad < 5).length,
    ),
    loading: () => SustratoStats.empty(),
    error: (_, __) => SustratoStats.empty(),
  );
});

class SustratoStats {
  final int total;
  final double valorTotal;
  final int bajosEnStock;

  SustratoStats({required this.total, required this.valorTotal, required this.bajosEnStock});

  factory SustratoStats.empty() => SustratoStats(total: 0, valorTotal: 0, bajosEnStock: 0);
}
