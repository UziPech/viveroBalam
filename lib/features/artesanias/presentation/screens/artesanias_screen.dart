import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../../../core/services/image_service.dart';
import '../../domain/entities/artesania.dart';
import '../providers/artesania_provider.dart';
import '../widgets/artesania_card.dart';
import '../widgets/nueva_artesania_form.dart';
import '../widgets/artesania_detail_modal.dart';

/// Pantalla principal del catálogo de artesanías
class ArtesaniasScreen extends ConsumerStatefulWidget {
  const ArtesaniasScreen({super.key});

  @override
  ConsumerState<ArtesaniasScreen> createState() => _ArtesaniasScreenState();
}

class _ArtesaniasScreenState extends ConsumerState<ArtesaniasScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NuevaArtesaniaForm(),
    );
  }

  Future<void> _delete(Artesania artesania) async {
    if (artesania.fotoPath.isNotEmpty) {
      final imageService = ref.read(artesaniaImageServiceProvider);
      await imageService.deletePhoto(artesania.fotoPath);
    }
    await ref.read(artesaniaRepoProvider).deleteArtesania(artesania);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final artesaniasAsync = ref.watch(artesaniasStreamProvider);

    return Scaffold(
      backgroundColor: AppDesign.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDesign.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🏺 Artesanías", style: AppDesign.title1),
                  const Gap(AppDesign.space4),
                  Text("Productos decorativos", style: AppDesign.caption),
                ],
              ),
            ),
            Expanded(
              child: artesaniasAsync.when(
                data: (items) => items.isEmpty ? _buildEmpty() : _buildList(items),
                loading: () => const Center(child: CircularProgressIndicator(color: AppDesign.gray900)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: artesaniasAsync.maybeWhen(
        data: (items) => items.isNotEmpty ? _buildFAB() : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildList(List<Artesania> items) {
    final valorTotal = items.fold<double>(0, (sum, a) => sum + a.precio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Row(
            children: [
              Expanded(child: _buildStat("${items.length}", "Artesanías", Icons.emoji_objects_rounded)),
              const Gap(AppDesign.space12),
              Expanded(child: _buildStat("\$${valorTotal.toStringAsFixed(0)}", "Valor", Icons.attach_money_rounded)),
            ],
          ).animate().fadeIn(),
        ),
        const Gap(AppDesign.space16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Text("${items.length} artesanía${items.length != 1 ? 's' : ''}", style: AppDesign.footnote),
        ),
        const Gap(AppDesign.space12),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: AppDesign.navBarSpace + AppDesign.space16),
            itemCount: items.length,
            itemBuilder: (ctx, i) => ArtesaniaCard(
              artesania: items[i],
              index: i,
              onDelete: () => _delete(items[i]),
              onTap: () => ArtesaniaDetailModal.show(context, items[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space16),
      decoration: AppDesign.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppDesign.gray400),
          const Gap(AppDesign.space8),
          Text(value, style: AppDesign.title3, maxLines: 1, overflow: TextOverflow.ellipsis),
          const Gap(AppDesign.space4),
          Text(label, style: AppDesign.footnote),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppDesign.gray100, borderRadius: BorderRadius.circular(AppDesign.radiusLarge)),
            child: const Center(child: Text("🏺", style: TextStyle(fontSize: 48))),
          ),
          const Gap(AppDesign.space24),
          const Text("Sin artesanías", style: AppDesign.title3),
          const Gap(AppDesign.space8),
          Text("Agrega tu primera artesanía", textAlign: TextAlign.center, style: AppDesign.caption),
          const Gap(AppDesign.space32),
          GestureDetector(
            onTap: _showAddModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDesign.space24, vertical: AppDesign.space16),
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
                  Text("Agregar Artesanía", style: AppDesign.bodyBold.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.navBarSpace),
      child: GestureDetector(
        onTap: _showAddModal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.space20, vertical: AppDesign.space16),
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
              Text("Nueva", style: AppDesign.bodyBold.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 300.ms);
  }
}
