import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/product.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_card_modern.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showAddProductModal(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: AppDesign.space20,
          left: AppDesign.screenPadding,
          right: AppDesign.screenPadding,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDesign.space24,
        ),
        decoration: BoxDecoration(
          color: AppDesign.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDesign.radiusXL),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppDesign.gray300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const Gap(AppDesign.space24),
              const Text("Nuevo Producto", style: AppDesign.title2),
              const Gap(AppDesign.space8),
              const Text("Completa la información", style: AppDesign.caption),
              const Gap(AppDesign.space24),
              _buildInput(nameController, "Nombre", Icons.inventory_2_outlined),
              const Gap(AppDesign.space16),
              _buildInput(categoryController, "Categoría", Icons.tag_rounded),
              const Gap(AppDesign.space16),
              Row(
                children: [
                  Expanded(child: _buildInput(priceController, "Precio", Icons.attach_money, isNumber: true)),
                  const Gap(AppDesign.space16),
                  Expanded(child: _buildInput(stockController, "Stock", Icons.numbers, isNumber: true)),
                ],
              ),
              const Gap(AppDesign.space32),
              _buildButton(
                label: "Agregar",
                onTap: () {
                  if (nameController.text.isNotEmpty) {
                    final newProduct = Product()
                      ..name = nameController.text
                      ..salePrice = double.tryParse(priceController.text) ?? 0.0
                      ..costPrice = 0.0
                      ..currentStock = int.tryParse(stockController.text) ?? 0
                      ..minStock = 5
                      ..barcode = DateTime.now().millisecondsSinceEpoch.toString()
                      ..category = categoryController.text
                      ..createdAt = DateTime.now();

                    ref.read(inventoryRepoProvider).saveProduct(newProduct);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesign.gray50,
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: AppDesign.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppDesign.caption,
          prefixIcon: Icon(icon, color: AppDesign.gray400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDesign.space16),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppDesign.gray900,
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          boxShadow: AppDesign.shadowMedium,
        ),
        child: Center(
          child: Text(label, style: AppDesign.bodyBold.copyWith(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final productListAsync = ref.watch(productsStreamProvider);

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
                  const Text("Inventario", style: AppDesign.title1),
                  _buildIconButton(Icons.search_rounded, () {}),
                ],
              ),
            ),

            // Content
            Expanded(
              child: productListAsync.when(
                data: (products) {
                  if (products.isEmpty) return _buildEmptyState();
                  return _buildProductList(products);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppDesign.gray900),
                ),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
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

  Widget _buildProductList(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: _buildStats(products),
        ),
        const Gap(AppDesign.space16),

        // List header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Text("${products.length} productos", style: AppDesign.footnote),
        ),
        const Gap(AppDesign.space12),

        // Products
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: AppDesign.navBarSpace + AppDesign.space16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCardModern(
                product: products[index],
                index: index,
                onDelete: () {
                  ref.read(inventoryRepoProvider).deleteProduct(products[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats(List<Product> products) {
    final lowStock = products.where((p) => p.currentStock <= p.minStock).length;
    final totalValue = products.fold<double>(0, (sum, p) => sum + (p.salePrice * p.currentStock));

    return Row(
      children: [
        Expanded(child: _buildStatCard("${products.length}", "Productos")),
        const Gap(AppDesign.space12),
        Expanded(child: _buildStatCard("$lowStock", "Stock bajo", isWarning: lowStock > 0)),
        const Gap(AppDesign.space12),
        Expanded(child: _buildStatCard("\$${totalValue.toStringAsFixed(0)}", "Valor")),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStatCard(String value, String label, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: AppDesign.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppDesign.title3.copyWith(
              color: isWarning ? AppDesign.accentWarning : AppDesign.gray900,
            ),
          ),
          const Gap(AppDesign.space4),
          Text(label, style: AppDesign.footnote),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppDesign.gray500),
          ),
          const Gap(AppDesign.space24),
          const Text("Sin productos", style: AppDesign.title3),
          const Gap(AppDesign.space8),
          const Text("Agrega tu primer producto", style: AppDesign.caption),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.navBarSpace),
      child: GestureDetector(
        onTap: () => _showAddProductModal(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space20,
            vertical: AppDesign.space16,
          ),
          decoration: BoxDecoration(
            color: AppDesign.gray900,
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            boxShadow: AppDesign.shadowLarge,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const Gap(AppDesign.space8),
              Text("Nuevo", style: AppDesign.bodyBold.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 300.ms, duration: 300.ms);
  }
}
