import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/artesania_repository.dart';
import '../../domain/entities/artesania.dart';
import '../../../../core/services/image_service.dart';

// ==================== PROVIDERS DE INFRAESTRUCTURA ====================

final hiveBoxArtesaniasProvider = Provider<Box<Artesania>>((ref) {
  return Hive.box<Artesania>('artesanias');
});

final artesaniaRepoProvider = Provider<ArtesaniaRepository>((ref) {
  final box = ref.watch(hiveBoxArtesaniasProvider);
  return ArtesaniaRepository(box);
});

final artesaniaImageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

// ==================== PROVIDERS DE DATOS ====================

final artesaniasStreamProvider = StreamProvider<List<Artesania>>((ref) {
  final repo = ref.watch(artesaniaRepoProvider);
  return repo.watchAllArtesanias();
});

/// Estadísticas de artesanías
final artesaniasStatsProvider = Provider<ArtesaniaStats>((ref) {
  final artesaniasAsync = ref.watch(artesaniasStreamProvider);
  
  return artesaniasAsync.when(
    data: (artesanias) => ArtesaniaStats(
      total: artesanias.length,
      valorTotal: artesanias.fold(0, (sum, a) => sum + a.precio),
    ),
    loading: () => ArtesaniaStats.empty(),
    error: (_, __) => ArtesaniaStats.empty(),
  );
});

class ArtesaniaStats {
  final int total;
  final double valorTotal;

  ArtesaniaStats({required this.total, required this.valorTotal});

  factory ArtesaniaStats.empty() => ArtesaniaStats(total: 0, valorTotal: 0);
}
