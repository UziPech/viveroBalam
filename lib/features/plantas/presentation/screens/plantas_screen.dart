import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/widgets/animated_search_bar.dart';
import '../../domain/entities/planta.dart';
import '../providers/planta_provider.dart';
import '../widgets/planta_card.dart';
import '../widgets/nueva_planta_form.dart';
import '../widgets/planta_detail_modal.dart';

/// Pantalla principal del catálogo de plantas
class PlantasScreen extends ConsumerStatefulWidget {
  const PlantasScreen({super.key});

  @override
  ConsumerState<PlantasScreen> createState() => _PlantasScreenState();
}

class _PlantasScreenState extends ConsumerState<PlantasScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Estado de búsqueda
  String _searchQuery = '';

  /// Abre el formulario de nueva planta
  void _showAddPlantaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NuevaPlantaForm(),
    );
  }

  /// Elimina una planta (con confirmación visual via swipe)
  Future<void> _deletePlanta(Planta planta) async {
    // Eliminar foto asociada
    if (planta.fotoPath.isNotEmpty) {
      final imageService = ref.read(imageServiceProvider);
      await imageService.deletePhoto(planta.fotoPath);
    }
    // Eliminar de la base de datos
    await ref.read(plantaRepoProvider).deletePlanta(planta);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final plantasAsync = ref.watch(plantasStreamProvider);

    return Scaffold(
      backgroundColor: AppDesign.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER ==========
            Padding(
              padding: const EdgeInsets.all(AppDesign.screenPadding),
              child: SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    // Título
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🌿 Catálogo", style: AppDesign.title1),
                        const Gap(AppDesign.space4),
                        Text(
                          "Vivero de Plantas",
                          style: AppDesign.caption,
                        ),
                      ],
                    ),
                    // Buscador animado (se posiciona a la derecha)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: AnimatedSearchBar(
                        onSearch: (query) {
                          setState(() => _searchQuery = query);
                        },
                        hintText: 'Buscar planta...',
                        expandedWidth: MediaQuery.of(context).size.width - 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ========== CONTENIDO ==========
            Expanded(
              child: plantasAsync.when(
                data: (plantas) {
                  if (plantas.isEmpty) return _buildEmptyState();
                  // Filtrar plantas según búsqueda
                  final filtered = _searchQuery.isEmpty
                      ? plantas
                      : plantas.where((p) =>
                          p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          p.categoria.toLowerCase().contains(_searchQuery.toLowerCase())
                        ).toList();
                  if (filtered.isEmpty && _searchQuery.isNotEmpty) {
                    return _buildNoResults();
                  }
                  return _buildPlantasList(filtered);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppDesign.gray900),
                ),
                error: (err, _) => Center(
                  child: Text('Error: $err', style: AppDesign.body),
                ),
              ),
            ),
          ],
        ),
      ),
      // Solo mostrar FAB cuando hay plantas
      floatingActionButton: plantasAsync.maybeWhen(
        data: (plantas) => plantas.isNotEmpty ? _buildFAB() : null,
        orElse: () => null,
      ),
    );
  }

  /// Cuando no hay resultados de búsqueda
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppDesign.gray300),
          const Gap(AppDesign.space16),
          Text(
            'No se encontraron plantas',
            style: AppDesign.title3,
          ),
          const Gap(AppDesign.space8),
          Text(
            'Intenta con otro término de búsqueda',
            style: AppDesign.caption,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  /// Lista de plantas con estadísticas
  Widget _buildPlantasList(List<Planta> plantas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estadísticas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: _buildStats(plantas),
        ),
        const Gap(AppDesign.space16),

        // Contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Text(
            "${plantas.length} planta${plantas.length != 1 ? 's' : ''}",
            style: AppDesign.footnote,
          ),
        ),
        const Gap(AppDesign.space12),

        // Lista de plantas
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: AppDesign.navBarSpace + AppDesign.space16),
            itemCount: plantas.length,
            itemBuilder: (context, index) {
              return PlantaCard(
                planta: plantas[index],
                index: index,
                onDelete: () => _deletePlanta(plantas[index]),
                onTap: () => PlantaDetailModal.show(context, plantas[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tarjetas de estadísticas
  Widget _buildStats(List<Planta> plantas) {
    // Contar por categorías
    final categorias = <String, int>{};
    for (final p in plantas) {
      categorias[p.categoria] = (categorias[p.categoria] ?? 0) + 1;
    }
    final topCategoria = categorias.entries.isNotEmpty
        ? categorias.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    // Valor total del catálogo
    final valorTotal = plantas.fold<double>(0, (sum, p) => sum + p.precio);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "${plantas.length}",
            "Plantas",
            Icons.local_florist_rounded,
          ),
        ),
        const Gap(AppDesign.space12),
        Expanded(
          child: _buildStatCard(
            topCategoria,
            "Top Categoría",
            Icons.category_rounded,
          ),
        ),
        const Gap(AppDesign.space12),
        Expanded(
          child: _buildStatCard(
            "\$${valorTotal.toStringAsFixed(0)}",
            "Valor",
            Icons.attach_money_rounded,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Tarjeta individual de estadística
  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: AppDesign.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppDesign.gray400),
          const Gap(AppDesign.space8),
          Text(
            value,
            style: AppDesign.title3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppDesign.space4),
          Text(label, style: AppDesign.footnote),
        ],
      ),
    );
  }

  /// Estado vacío cuando no hay plantas
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppDesign.gray100,
              borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            ),
            child: const Center(
              child: Text(
                "🌱",
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),
          const Gap(AppDesign.space24),
          const Text("Sin plantas aún", style: AppDesign.title3),
          const Gap(AppDesign.space8),
          Text(
            "Agrega tu primera planta\ncon el botón +",
            textAlign: TextAlign.center,
            style: AppDesign.caption,
          ),
          const Gap(AppDesign.space32),
          GestureDetector(
            onTap: _showAddPlantaModal,
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
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  const Gap(AppDesign.space8),
                  Text(
                    "Agregar Planta",
                    style: AppDesign.bodyBold.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// Botón flotante para agregar planta
  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.navBarSpace),
      child: GestureDetector(
        onTap: _showAddPlantaModal,
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
              Text(
                "Nueva",
                style: AppDesign.bodyBold.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 300.ms, duration: 300.ms);
  }
}
