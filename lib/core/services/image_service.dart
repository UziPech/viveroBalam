import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para captura, compresión y gestión de imágenes de plantas
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Obtiene el directorio donde se guardan las fotos de plantas
  Future<Directory> get _plantasDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final plantasDir = Directory('${appDir.path}/plantas_fotos');
    if (!await plantasDir.exists()) {
      await plantasDir.create(recursive: true);
    }
    return plantasDir;
  }

  /// Toma foto con cámara, comprime y guarda localmente
  /// 
  /// Retorna la ruta del archivo guardado o null si el usuario cancela
  /// La imagen se redimensiona a máximo 1024px y se comprime al 50% de calidad
  Future<String?> captureAndSavePhoto() async {
    try {
      // 1. Capturar foto con la cámara
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920, // Limitar tamaño inicial
        maxHeight: 1920,
      );

      if (photo == null) return null;

      // 2. Generar nombre único basado en timestamp
      final fileName = 'planta_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dir = await _plantasDir;
      final targetPath = '${dir.path}/$fileName';

      // 3. Comprimir y redimensionar (max 1024px, calidad 50%)
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        photo.path,
        targetPath,
        quality: 50,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        // Fallback: copiar sin comprimir si la compresión falla
        await File(photo.path).copy(targetPath);
        return targetPath;
      }

      return compressedFile.path;
    } catch (e) {
      // ignore: avoid_print
      print('Error capturando foto: $e');
      return null;
    }
  }

  /// Selecciona foto de la galería, comprime y guarda localmente
  Future<String?> pickFromGalleryAndSave() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo == null) return null;

      final fileName = 'planta_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dir = await _plantasDir;
      final targetPath = '${dir.path}/$fileName';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        photo.path,
        targetPath,
        quality: 50,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        await File(photo.path).copy(targetPath);
        return targetPath;
      }

      return compressedFile.path;
    } catch (e) {
      // ignore: avoid_print
      print('Error seleccionando foto: $e');
      return null;
    }
  }

  /// Elimina una foto del almacenamiento local
  Future<void> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error eliminando foto: $e');
    }
  }

  /// Obtiene la ruta del directorio de fotos (para exportación)
  Future<String> getPhotosDirectoryPath() async {
    final dir = await _plantasDir;
    return dir.path;
  }

  /// Verifica si una foto existe en el almacenamiento local
  Future<bool> photoExists(String photoPath) async {
    if (photoPath.isEmpty) return false;
    return await File(photoPath).exists();
  }

  /// Obtiene el tamaño total de las fotos almacenadas (en bytes)
  Future<int> getTotalPhotosSize() async {
    try {
      final dir = await _plantasDir;
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (final file in dir.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Formatea bytes a string legible (KB, MB)
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
