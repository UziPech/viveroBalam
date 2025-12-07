import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_design.dart';
import '../../domain/entities/sustrato.dart';
import '../providers/sustrato_provider.dart';
import '../../../../features/categorias/domain/entities/categoria.dart';

/// Formulario para crear nuevo sustrato
class NuevoSustratoForm extends ConsumerStatefulWidget {
  const NuevoSustratoForm({super.key});

  @override
  ConsumerState<NuevoSustratoForm> createState() => _NuevoSustratoFormState();
}

class _NuevoSustratoFormState extends ConsumerState<NuevoSustratoForm> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _descripcionController = TextEditingController();

  String? _fotoPath;
  String _categoria = 'Tierra';
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);
    try {
      final imageService = ref.read(sustratoImageServiceProvider);
      final path = await imageService.captureAndSavePhoto();
      if (path != null && mounted) setState(() => _fotoPath = path);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final imageService = ref.read(sustratoImageServiceProvider);
      final path = await imageService.pickFromGalleryAndSave();
      if (path != null && mounted) setState(() => _fotoPath = path);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Ingresa el nombre'), backgroundColor: AppDesign.accentWarning, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final sustrato = Sustrato.create(
      nombre: nombre,
      precio: double.tryParse(_precioController.text) ?? 0.0,
      cantidad: int.tryParse(_cantidadController.text) ?? 0,
      descripcion: _descripcionController.text.trim(),
      categoria: _categoria,
      fotoPath: _fotoPath ?? '',
    );

    await ref.read(sustratoRepoProvider).saveSustrato(sustrato);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${sustrato.nombre} agregado'), backgroundColor: AppDesign.accentSuccess, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDesign.space20, left: AppDesign.screenPadding, right: AppDesign.screenPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDesign.space24,
      ),
      decoration: BoxDecoration(color: AppDesign.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radiusXL))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 36, height: 5, decoration: BoxDecoration(color: AppDesign.gray300, borderRadius: BorderRadius.circular(3)))),
            const Gap(AppDesign.space16),
            const Text("Nuevo Sustrato 🌱", style: AppDesign.title2),
            const Gap(AppDesign.space20),

            _buildCameraWidget(),
            const Gap(AppDesign.space20),

            _buildTextField(_nombreController, "Nombre", Icons.label_rounded),
            const Gap(AppDesign.space12),

            Row(
              children: [
                Expanded(child: _buildTextField(_precioController, "Precio \$", Icons.attach_money_rounded, isNumber: true)),
                const Gap(AppDesign.space12),
                Expanded(child: _buildTextField(_cantidadController, "Cantidad", Icons.inventory_2_rounded, isNumber: true)),
              ],
            ),
            const Gap(AppDesign.space12),

            _buildTextField(_descripcionController, "Descripción (opcional)", Icons.description_rounded, maxLines: 2),
            const Gap(AppDesign.space16),

            const Text("Categoría", style: AppDesign.footnote),
            const Gap(AppDesign.space8),
            _buildCategoriaDropdown(),
            const Gap(AppDesign.space24),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraWidget() {
    final hasPhoto = _fotoPath != null;
    return GestureDetector(
      onTap: _isLoading ? null : _showPhotoOptions,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppDesign.gray100,
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          image: hasPhoto ? DecorationImage(image: FileImage(File(_fotoPath!)), fit: BoxFit.cover) : null,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasPhoto
                ? Align(alignment: Alignment.bottomCenter, child: Container(
                    padding: const EdgeInsets.all(AppDesign.space8),
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(100)])),
                    child: Text("Cambiar foto", style: AppDesign.footnote.copyWith(color: Colors.white)),
                  ))
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.camera_alt_rounded, size: 40, color: AppDesign.gray400),
                    const Gap(AppDesign.space8),
                    Text("Tocar para foto", style: AppDesign.caption),
                  ]),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppDesign.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radiusLarge))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDesign.space24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: Icon(Icons.camera_alt_rounded), title: const Text("Tomar foto"), onTap: () { Navigator.pop(ctx); _takePhoto(); }),
          ListTile(leading: Icon(Icons.photo_library_rounded), title: const Text("Elegir de galería"), onTap: () { Navigator.pop(ctx); _pickFromGallery(); }),
        ]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: AppDesign.gray50, borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
      child: TextField(
        controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, maxLines: maxLines, style: AppDesign.body,
        decoration: InputDecoration(hintText: hint, hintStyle: AppDesign.caption, prefixIcon: Icon(icon, color: AppDesign.gray400, size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.all(AppDesign.space16)),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    final categorias = Categoria.getPredefinidas('sustrato');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDesign.space16),
      decoration: BoxDecoration(color: AppDesign.gray50, borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
      child: DropdownButton<String>(
        value: _categoria, isExpanded: true, underline: const SizedBox(), style: AppDesign.body.copyWith(color: AppDesign.gray900),
        items: categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
        onChanged: (value) { if (value != null) setState(() => _categoria = value); },
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 52,
        decoration: BoxDecoration(color: AppDesign.gray900, borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
        child: Center(child: Text("Guardar", style: AppDesign.bodyBold.copyWith(color: Colors.white))),
      ),
    );
  }
}
