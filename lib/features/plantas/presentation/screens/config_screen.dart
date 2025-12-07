import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../providers/planta_provider.dart';

/// Pantalla de configuración con opciones de sincronización
class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isExporting = false;
  bool _isImporting = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final syncService = ref.read(syncServiceProvider);
    final stats = await syncService.getStats();
    if (mounted) {
      setState(() => _stats = stats);
    }
  }

  Future<void> _exportar() async {
    setState(() => _isExporting = true);
    
    try {
      final syncService = ref.read(syncServiceProvider);
      final success = await syncService.exportarCatalogo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '¡Catálogo exportado!' : 'Error al exportar',
            ),
            backgroundColor: success ? AppDesign.accentSuccess : AppDesign.accentError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importar() async {
    // Mostrar confirmación primero
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        title: const Text("⚠️ Importar Catálogo", style: AppDesign.title2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Esta acción reemplazará TODOS los datos actuales.",
              style: AppDesign.body,
            ),
            const Gap(AppDesign.space12),
            Text(
              "• Se eliminarán ${_stats?['plantasCount'] ?? 0} plantas actuales\n"
              "• Se borrarán todas las fotos existentes\n"
              "• No se puede deshacer",
              style: AppDesign.footnote.copyWith(color: AppDesign.accentWarning),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancelar",
              style: AppDesign.body.copyWith(color: AppDesign.gray500),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppDesign.accentWarning,
            ),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isImporting = true);

    try {
      final syncService = ref.read(syncServiceProvider);
      final importadas = await syncService.importarCatalogo();
      
      if (mounted) {
        String mensaje;
        Color color;
        
        if (importadas > 0) {
          mensaje = '¡$importadas plantas importadas!';
          color = AppDesign.accentSuccess;
        } else if (importadas == 0) {
          mensaje = 'No se seleccionó archivo';
          color = AppDesign.gray500;
        } else {
          mensaje = 'Error al importar';
          color = AppDesign.accentError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
            ),
          ),
        );

        // Recargar estadísticas
        _loadStats();
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _limpiarTodo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        title: const Text("🗑️ Eliminar Todo", style: AppDesign.title2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Estás seguro de eliminar TODOS los datos?",
              style: AppDesign.body,
            ),
            const Gap(AppDesign.space12),
            Text(
              "• ${_stats?['plantasCount'] ?? 0} plantas\n"
              "• ${_stats?['fotosCount'] ?? 0} fotos (${_stats?['fotosSizeFormatted'] ?? '0 B'})\n"
              "• Esta acción NO se puede deshacer",
              style: AppDesign.footnote.copyWith(color: AppDesign.accentError),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancelar",
              style: AppDesign.body.copyWith(color: AppDesign.gray500),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppDesign.accentError,
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final syncService = ref.read(syncServiceProvider);
    await syncService.limpiarTodo();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Todos los datos eliminados'),
          backgroundColor: AppDesign.gray900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          ),
        ),
      );
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppDesign.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesign.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text("⚙️ Configuración", style: AppDesign.title1),
              const Gap(AppDesign.space8),
              const Text("Sincronización y datos", style: AppDesign.caption),
              const Gap(AppDesign.space32),

              // Estadísticas
              _buildStatsCard(),
              const Gap(AppDesign.space24),

              // Sección Sincronización
              const Text("Sincronización", style: AppDesign.title3),
              const Gap(AppDesign.space12),

              // Exportar
              _buildActionCard(
                icon: Icons.upload_rounded,
                title: "Exportar Catálogo",
                subtitle: "Crear archivo ZIP para compartir",
                onTap: _isExporting ? null : _exportar,
                isLoading: _isExporting,
                color: AppDesign.gray900,
              ),
              const Gap(AppDesign.space12),

              // Importar
              _buildActionCard(
                icon: Icons.download_rounded,
                title: "Importar Catálogo",
                subtitle: "Cargar desde archivo ZIP",
                onTap: _isImporting ? null : _importar,
                isLoading: _isImporting,
                color: AppDesign.accentWarning,
              ),
              const Gap(AppDesign.space32),

              // Sección Datos
              const Text("Datos", style: AppDesign.title3),
              const Gap(AppDesign.space12),

              // Limpiar
              _buildActionCard(
                icon: Icons.delete_forever_rounded,
                title: "Eliminar Todo",
                subtitle: "Borrar plantas y fotos",
                onTap: _limpiarTodo,
                color: AppDesign.accentError,
              ),

              const Gap(AppDesign.space24 + AppDesign.navBarSpace),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.space20),
      decoration: AppDesign.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppDesign.gray500),
              const Gap(AppDesign.space8),
              const Text("Estado del Catálogo", style: AppDesign.bodyBold),
            ],
          ),
          const Gap(AppDesign.space16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "🌱",
                  "${_stats?['plantasCount'] ?? '-'}",
                  "Plantas",
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  "📸",
                  "${_stats?['fotosCount'] ?? '-'}",
                  "Fotos",
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  "💾",
                  _stats?['fotosSizeFormatted'] ?? '-',
                  "Tamaño",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const Gap(AppDesign.space4),
        Text(
          value,
          style: AppDesign.bodyBold,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(2),
        Text(
          label,
          style: AppDesign.footnote.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Color color,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDesign.space16),
        decoration: AppDesign.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(icon, color: color, size: 24),
            ),
            const Gap(AppDesign.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppDesign.bodyBold),
                  const Gap(AppDesign.space4),
                  Text(subtitle, style: AppDesign.footnote),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppDesign.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
