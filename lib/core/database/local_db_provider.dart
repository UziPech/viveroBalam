import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/inventory/domain/entities/product.dart';

// Provider que proporciona la caja de productos ya abierta
final hiveBoxProvider = Provider<Box<Product>>((ref) {
  // La caja ya está abierta desde main.dart
  return Hive.box<Product>('products');
});
