import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/planta.dart';
import '../providers/planta_provider.dart';

/// Formulario optimizado para alta rápida de plantas (< 10 segundos)
/// Flujo: Foto -> Nombre -> Precio -> Luz/Riego -> Guardar
class NuevaPlantaForm extends ConsumerStatefulWidget {
  const NuevaPlantaForm({super.key});

  @override
  ConsumerState<NuevaPlantaForm> createState() => _NuevaPlantaFormState();
}

class _NuevaPlantaFormState extends ConsumerState<NuevaPlantaForm> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();

  String? _fotoPath;
  TipoLuz _tipoLuz = TipoLuz.sol;
  FrecuenciaRiego _frecuenciaRiego = FrecuenciaRiego.semanal;
  String _categoria = 'Suculenta';
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  /// Captura foto con la cámara
  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);
    
    try {
      final imageService = ref.read(imageServiceProvider);
      final path = await imageService.captureAndSavePhoto();
      
      if (path != null && mounted) {
        setState(() => _fotoPath = path);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Selecciona foto de galería
  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    
    try {
      final imageService = ref.read(imageServiceProvider);
      final path = await imageService.pickFromGalleryAndSave();
      
      if (path != null && mounted) {
        setState(() => _fotoPath = path);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Guarda la planta
  Future<void> _save() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresa el nombre de la planta'),
          backgroundColor: AppDesign.accentWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          ),
        ),
      );
      return;
    }

    final planta = Planta.create(
      nombre: nombre,
      precio: double.tryParse(_precioController.text) ?? 0.0,
      categoria: _categoria,
      tipoLuz: _tipoLuz,
      frecuenciaRiego: _frecuenciaRiego,
      fotoPath: _fotoPath ?? '',
    );

    await ref.read(plantaRepoProvider).savePlanta(planta);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${planta.nombre} agregada'),
          backgroundColor: AppDesign.accentSuccess,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDesign.space20,
        left: AppDesign.screenPadding,
        right: AppDesign.screenPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDesign.space24,
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
            // Handle
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
            const Gap(AppDesign.space16),

            // Título
            const Text("Nueva Planta 🌱", style: AppDesign.title2),
            const Gap(AppDesign.space8),
            const Text("Completa la información", style: AppDesign.caption),
            const Gap(AppDesign.space20),

            // ============ FOTO (Prioridad #1) ============
            _buildCameraWidget(),
            const Gap(AppDesign.space20),

            // ============ NOMBRE ============
            _buildTextField(
              controller: _nombreController,
              hint: "Nombre de la planta",
              icon: Icons.local_florist_rounded,
            ),
            const Gap(AppDesign.space16),

            // ============ PRECIO ============
            _buildTextField(
              controller: _precioController,
              hint: "Precio \$",
              icon: Icons.attach_money_rounded,
              isNumber: true,
            ),
            const Gap(AppDesign.space20),

            // ============ TIPO DE LUZ ============
            _buildLabel("Tipo de Luz"),
            const Gap(AppDesign.space8),
            _buildLuzSelector(),
            const Gap(AppDesign.space16),

            // ============ FRECUENCIA DE RIEGO ============
            _buildLabel("Frecuencia de Riego"),
            const Gap(AppDesign.space8),
            _buildRiegoSelector(),
            const Gap(AppDesign.space16),

            // ============ CATEGORÍA ============
            _buildLabel("Categoría"),
            const Gap(AppDesign.space8),
            _buildCategoriaDropdown(),
            const Gap(AppDesign.space24),

            // ============ BOTÓN GUARDAR ============
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Widget de cámara grande con placeholder y acción de captura
  Widget _buildCameraWidget() {
    final hasPhoto = _fotoPath != null;

    return GestureDetector(
      onTap: _isLoading ? null : _showPhotoOptions,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppDesign.gray100,
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          image: hasPhoto
              ? DecorationImage(
                  image: FileImage(File(_fotoPath!)),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: AppDesign.shadowSmall,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasPhoto
                ? _buildPhotoOverlay()
                : _buildCameraPlaceholder(),
      ),
    );
  }

  /// Placeholder cuando no hay foto
  Widget _buildCameraPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt_rounded,
          size: 48,
          color: AppDesign.gray400,
        ),
        const Gap(AppDesign.space8),
        Text(
          "Tocar para foto",
          style: AppDesign.caption,
        ),
      ],
    );
  }

  /// Overlay sobre la foto para indicar que se puede cambiar
  Widget _buildPhotoOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(100),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.space12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              const Gap(AppDesign.space4),
              Text(
                "Cambiar foto",
                style: AppDesign.footnote.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra opciones para cámara o galería
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppDesign.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesign.radiusLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDesign.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDesign.space12),
                decoration: BoxDecoration(
                  color: AppDesign.gray100,
                  borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                ),
                child: Icon(Icons.camera_alt_rounded, color: AppDesign.gray700),
              ),
              title: const Text("Tomar foto", style: AppDesign.bodyBold),
              subtitle: const Text("Usar cámara", style: AppDesign.footnote),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
            const Gap(AppDesign.space8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDesign.space12),
                decoration: BoxDecoration(
                  color: AppDesign.gray100,
                  borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                ),
                child: Icon(Icons.photo_library_rounded, color: AppDesign.gray700),
              ),
              title: const Text("Elegir de galería", style: AppDesign.bodyBold),
              subtitle: const Text("Seleccionar foto existente", style: AppDesign.footnote),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Selector de tipo de luz con chips
  Widget _buildLuzSelector() {
    return Row(
      children: [
        _buildChip(
          "☀️ Sol",
          _tipoLuz == TipoLuz.sol,
          () => setState(() => _tipoLuz = TipoLuz.sol),
        ),
        const Gap(AppDesign.space8),
        _buildChip(
          "☁️ Sombra",
          _tipoLuz == TipoLuz.sombra,
          () => setState(() => _tipoLuz = TipoLuz.sombra),
        ),
        const Gap(AppDesign.space8),
        _buildChip(
          "⛅ Media",
          _tipoLuz == TipoLuz.mediaSombra,
          () => setState(() => _tipoLuz = TipoLuz.mediaSombra),
        ),
      ],
    );
  }

  /// Selector de frecuencia de riego con chips
  Widget _buildRiegoSelector() {
    return Row(
      children: [
        _buildChip(
          "💧 Diario",
          _frecuenciaRiego == FrecuenciaRiego.diario,
          () => setState(() => _frecuenciaRiego = FrecuenciaRiego.diario),
        ),
        const Gap(AppDesign.space8),
        _buildChip(
          "💧 2 días",
          _frecuenciaRiego == FrecuenciaRiego.cadaDosDias,
          () => setState(() => _frecuenciaRiego = FrecuenciaRiego.cadaDosDias),
        ),
        const Gap(AppDesign.space8),
        _buildChip(
          "💧💧 Sem",
          _frecuenciaRiego == FrecuenciaRiego.semanal,
          () => setState(() => _frecuenciaRiego = FrecuenciaRiego.semanal),
        ),
      ],
    );
  }

  /// Chip seleccionable
  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppDesign.space12),
          decoration: BoxDecoration(
            color: selected ? AppDesign.gray900 : AppDesign.gray50,
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            boxShadow: selected ? AppDesign.shadowSmall : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppDesign.bodyBold.copyWith(
                color: selected ? Colors.white : AppDesign.gray700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dropdown de categorías
  Widget _buildCategoriaDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
      decoration: BoxDecoration(
        color: AppDesign.gray50,
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
      ),
      child: DropdownButton<String>(
        value: _categoria,
        isExpanded: true,
        underline: const SizedBox(),
        style: AppDesign.body.copyWith(color: AppDesign.gray900),
        dropdownColor: AppDesign.surface,
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        items: PlantaStats.categoriasPredefinidas.map((cat) {
          return DropdownMenuItem(
            value: cat,
            child: Text(cat),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _categoria = value);
          }
        },
      ),
    );
  }

  /// Campo de texto estilizado
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
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
          hintText: hint,
          hintStyle: AppDesign.caption,
          prefixIcon: Icon(icon, color: AppDesign.gray400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDesign.space16),
        ),
      ),
    );
  }

  /// Etiqueta de sección
  Widget _buildLabel(String text) {
    return Text(text, style: AppDesign.footnote);
  }

  /// Botón de guardar
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppDesign.gray900,
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          boxShadow: AppDesign.shadowMedium,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_rounded, color: Colors.white, size: 22),
              const Gap(AppDesign.space8),
              Text(
                "Guardar Planta",
                style: AppDesign.bodyBold.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
