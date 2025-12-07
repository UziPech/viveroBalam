import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

class InventoryRepository {
  final Box<Product> _box;

  InventoryRepository(this._box);

  // 1. Guardar nuevo producto
  Future<void> saveProduct(Product product) async {
    await _box.add(product);
  }

  // 2. Obtener todos los productos
  List<Product> getAllProducts() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 3. Obtener producto por key
  Product? getProductByKey(dynamic key) {
    return _box.get(key);
  }

  // 4. Escuchar cambios en tiempo real (Stream)
  Stream<List<Product>> watchAllProducts() async* {
    yield getAllProducts();
    
    await for (final _ in _box.watch()) {
      yield getAllProducts();
    }
  }

  // 5. Borrar producto
  Future<void> deleteProduct(Product product) async {
    await _box.delete(product.key);
  }

  // 6. Actualizar producto por key
  Future<void> updateProduct(Product product) async {
    if (product.key != null) {
      await _box.put(product.key, product);
    }
  }

  // 7. Actualizar stock de un producto
  Future<void> updateStock(dynamic key, int newStock) async {
    final product = _box.get(key);
    if (product != null) {
      product.currentStock = newStock;
      await _box.put(key, product);
    }
  }
}
