import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/cart_provider.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showProductSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppDesign.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDesign.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(AppDesign.space16),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppDesign.gray300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const Gap(AppDesign.space16),
                    const Text("Agregar Producto", style: AppDesign.title2),
                  ],
                ),
              ),
              // Lista de productos
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final productsAsync = ref.watch(productsStreamProvider);
                    return productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return const Center(
                            child: Text("No hay productos", style: AppDesign.caption),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _buildProductTile(product, ctx);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTile(Product product, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        ref.read(cartProvider.notifier).addProduct(product);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} agregado'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppDesign.gray900,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.space12),
        padding: const EdgeInsets.all(AppDesign.space16),
        decoration: BoxDecoration(
          color: AppDesign.gray50,
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppDesign.gray900,
                borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              ),
              child: Center(
                child: Text(
                  product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                  style: AppDesign.bodyBold.copyWith(color: Colors.white),
                ),
              ),
            ),
            const Gap(AppDesign.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppDesign.bodyBold),
                  Text('Stock: ${product.currentStock}', style: AppDesign.footnote),
                ],
              ),
            ),
            Text('\$${product.salePrice.toStringAsFixed(2)}', style: AppDesign.price),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog() {
    final cart = ref.read(cartProvider);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        title: const Text("Confirmar Venta", style: AppDesign.title2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${cart.itemCount} productos", style: AppDesign.caption),
            const Gap(AppDesign.space8),
            Text(
              "Total: \$${cart.total.toStringAsFixed(2)}",
              style: AppDesign.title1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancelar", style: AppDesign.body.copyWith(color: AppDesign.gray500)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Ejecutar checkout que actualiza el stock
              final success = await ref.read(cartProvider.notifier).checkout();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '¡Venta completada! Stock actualizado.' : 'Error al procesar venta'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: success ? AppDesign.accentSuccess : AppDesign.accentError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                    ),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppDesign.gray900,
            ),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppDesign.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDesign.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ventas", style: AppDesign.title1),
                  _buildIconButton(Icons.add_rounded, _showProductSelector),
                ],
              ),
            ),

            // Content
            Expanded(
              child: cart.isEmpty ? _buildEmptyCart() : _buildCartContent(cart),
            ),
          ],
        ),
      ),
      // Footer de cobro
      bottomNavigationBar: cart.isEmpty ? null : _buildCheckoutFooter(cart),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppDesign.surface,
          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          boxShadow: AppDesign.shadowSmall,
        ),
        child: Icon(icon, color: AppDesign.gray900, size: 22),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppDesign.gray100,
              borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 40,
              color: AppDesign.gray500,
            ),
          ),
          const Gap(AppDesign.space24),
          const Text("Carrito vacío", style: AppDesign.title3),
          const Gap(AppDesign.space8),
          const Text(
            "Agrega productos para\niniciar una venta",
            textAlign: TextAlign.center,
            style: AppDesign.caption,
          ),
          const Gap(AppDesign.space32),
          _buildAddButton(),
          const Gap(AppDesign.navBarSpace),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showProductSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.space24,
          vertical: AppDesign.space16,
        ),
        decoration: BoxDecoration(
          color: AppDesign.gray900,
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          boxShadow: AppDesign.shadowMedium,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const Gap(AppDesign.space8),
            Text("Agregar Producto", style: AppDesign.bodyBold.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(CartState cart) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: AppDesign.screenPadding,
        right: AppDesign.screenPadding,
        bottom: AppDesign.navBarSpace + 100,
      ),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildCartItem(item, index);
      },
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDesign.space12),
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: AppDesign.cardDecoration,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppDesign.gray900,
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
            ),
            child: Center(
              child: Text(
                item.product.name.isNotEmpty ? item.product.name[0].toUpperCase() : '?',
                style: AppDesign.title3.copyWith(color: Colors.white),
              ),
            ),
          ),
          const Gap(AppDesign.space16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: AppDesign.bodyBold),
                const Gap(AppDesign.space4),
                Text(
                  '\$${item.product.salePrice.toStringAsFixed(2)} c/u',
                  style: AppDesign.footnote,
                ),
              ],
            ),
          ),

          // Controles de cantidad
          Row(
            children: [
              _buildQtyButton(
                Icons.remove,
                () => ref.read(cartProvider.notifier).decreaseQuantity(item.productKey),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text('${item.quantity}', style: AppDesign.bodyBold),
              ),
              _buildQtyButton(
                Icons.add,
                () => ref.read(cartProvider.notifier).addProduct(item.product),
              ),
            ],
          ),

          const Gap(AppDesign.space12),

          // Subtotal
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: AppDesign.price,
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().slideX(begin: 0.02);
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppDesign.gray100,
          borderRadius: BorderRadius.circular(AppDesign.space8),
        ),
        child: Icon(icon, size: 18, color: AppDesign.gray700),
      ),
    );
  }

  Widget _buildCheckoutFooter(CartState cart) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDesign.screenPadding,
        right: AppDesign.screenPadding,
        top: AppDesign.space20,
        bottom: AppDesign.navBarSpace + AppDesign.space8,
      ),
      decoration: BoxDecoration(
        color: AppDesign.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${cart.itemCount} productos", style: AppDesign.footnote),
                const Gap(AppDesign.space4),
                Text("\$${cart.total.toStringAsFixed(2)}", style: AppDesign.title1),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showCheckoutDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.space24,
                vertical: AppDesign.space16,
              ),
              decoration: BoxDecoration(
                color: AppDesign.gray900,
                borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
                boxShadow: AppDesign.shadowMedium,
              ),
              child: Row(
                children: [
                  const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 20),
                  const Gap(AppDesign.space8),
                  Text("Cobrar", style: AppDesign.bodyBold.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
