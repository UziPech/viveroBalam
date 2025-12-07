import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

/// Item del carrito de venta
class CartItem {
  final Product product;
  final dynamic productKey; // Guardamos el key para actualizaciones
  int quantity;

  CartItem({
    required this.product,
    required this.productKey,
    this.quantity = 1,
  });

  double get subtotal => product.salePrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      productKey: productKey,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Estado del carrito
class CartState {
  final List<CartItem> items;

  CartState({this.items = const []});

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

/// Notifier del carrito
class CartNotifier extends StateNotifier<CartState> {
  final Ref _ref;
  
  CartNotifier(this._ref) : super(CartState());

  /// Agregar producto al carrito
  void addProduct(Product product) {
    // Verificar si hay stock disponible
    final currentInCart = state.items
        .where((item) => item.productKey == product.key)
        .fold(0, (sum, item) => sum + item.quantity);
    
    if (currentInCart >= product.currentStock) {
      return; // No hay más stock
    }

    final existingIndex = state.items.indexWhere(
      (item) => item.productKey == product.key,
    );

    if (existingIndex >= 0) {
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [
        ...state.items,
        CartItem(product: product, productKey: product.key),
      ]);
    }
  }

  /// Quitar una unidad del producto
  void decreaseQuantity(dynamic productKey) {
    final existingIndex = state.items.indexWhere(
      (item) => item.productKey == productKey,
    );

    if (existingIndex >= 0) {
      final currentQty = state.items[existingIndex].quantity;
      if (currentQty > 1) {
        final updatedItems = [...state.items];
        updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
          quantity: currentQty - 1,
        );
        state = state.copyWith(items: updatedItems);
      } else {
        removeProduct(productKey);
      }
    }
  }

  /// Eliminar producto del carrito
  void removeProduct(dynamic productKey) {
    state = state.copyWith(
      items: state.items.where((item) => item.productKey != productKey).toList(),
    );
  }

  /// Completar venta y actualizar stock
  Future<bool> checkout() async {
    if (state.isEmpty) return false;

    try {
      final repo = _ref.read(inventoryRepoProvider);
      
      for (final item in state.items) {
        // Obtener producto fresco de la base de datos
        final freshProduct = repo.getProductByKey(item.productKey);
        if (freshProduct != null) {
          final newStock = freshProduct.currentStock - item.quantity;
          await repo.updateStock(item.productKey, newStock);
        }
      }
      
      state = CartState();
      return true;
    } catch (e) {
      // Error en checkout
      return false;
    }
  }

  /// Limpiar carrito sin actualizar stock
  void clear() {
    state = CartState();
  }
}

/// Provider del carrito
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
