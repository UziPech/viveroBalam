import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/local_db_provider.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../domain/entities/product.dart';

// Provider del Repositorio
final inventoryRepoProvider = Provider<InventoryRepository>((ref) {
  final box = ref.watch(hiveBoxProvider);
  return InventoryRepository(box);
});

// Stream Provider: La lista de productos "viva"
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(inventoryRepoProvider);
  return repo.watchAllProducts();
});
