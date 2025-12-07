import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../../../core/services/image_service.dart';
import '../../domain/entities/sustrato.dart';
import '../providers/sustrato_provider.dart';
import '../widgets/sustrato_card.dart';
import '../widgets/nuevo_sustrato_form.dart';
import '../widgets/sustrato_detail_modal.dart';

/// Pantalla principal del catálogo de sustratos
class SustratosScreen extends ConsumerStatefulWidget {
  const SustratosScreen({super.key});

  @override
  ConsumerState<SustratosScreen> createState() => _SustratosScreenState();
}

class _SustratosScreenState extends ConsumerState<SustratosScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NuevoSustratoForm(),
    );
  }

  Future<void> _delete(Sustrato sustrato) async {
    if (sustrato.fotoPath.isNotEmpty) {
      final imageService = ref.read(sustratoImageServiceProvider);
      await imageService.deletePhoto(sustrato.fotoPath);
    }
    await ref.read(sustratoRepoProvider).deleteSustrato(sustrato);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sustratosAsync = ref.watch(sustratosStreamProvider);

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
                  const Text("🌱 Sustratos", style: AppDesign.title1),
                  const Gap(AppDesign.space4),
                  Text("Materiales de jardinería", style: AppDesign.caption),
                ],
              ),
            ),
            Expanded(
              child: sustratosAsync.when(
                data: (items) => items.isEmpty ? _buildEmpty() : _buildList(items),
                loading: () => const Center(child: CircularProgressIndicator(color: AppDesign.gray900)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildList(List<Sustrato> items) {
    final valorTotal = items.fold<double>(0, (sum, s) => sum + s.precio);
    final bajosStock = items.where((s) => s.cantidad < 5).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Row(
            children: [
              Expanded(child: _buildStat("${items.length}", "Sustratos", Icons.grass_rounded)),
              const Gap(AppDesign.space12),
              Expanded(child: _buildStat("$bajosStock", "Bajo stock", Icons.warning_rounded)),
            ],
          ).animate().fadeIn(),
        ),
        const Gap(AppDesign.space16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Text("${items.length} sustrato${items.length != 1 ? 's' : ''}", style: AppDesign.footnote),
        ),
        const Gap(AppDesign.space12),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: AppDesign.navBarSpace + AppDesign.space16),
            itemCount: items.length,
            itemBuilder: (ctx, i) => SustratoCard(
              sustrato: items[i],
              index: i,
              onDelete: () => _delete(items[i]),
              onTap: () => SustratoDetailModal.show(context, items[i]),
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
            child: const Center(child: Text("🌱", style: TextStyle(fontSize: 48))),
          ),
          const Gap(AppDesign.space24),
          const Text("Sin sustratos", style: AppDesign.title3),
          const Gap(AppDesign.space8),
          Text("Agrega tu primer sustrato", style: AppDesign.caption),
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
          decoration: BoxDecoration(color: AppDesign.gray900, borderRadius: BorderRadius.circular(AppDesign.radiusMedium), boxShadow: AppDesign.shadowLarge),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const Gap(AppDesign.space8),
            Text("Nuevo", style: AppDesign.bodyBold.copyWith(color: Colors.white)),
          ]),
        ),
      ),
    ).animate().scale(delay: 300.ms);
  }
}
