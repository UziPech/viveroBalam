import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/plantas/domain/entities/planta.dart';

/// Servicio para exportar e importar el catálogo completo como archivo ZIP
/// Permite sincronización manual via WhatsApp u otros medios
class SyncService {
  final Box<Planta> _plantasBox;

  SyncService(this._plantasBox);

  /// Obtiene el directorio de fotos de plantas
  Future<Directory> get _fotosDir async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/plantas_fotos');
  }

  /// Exporta el catálogo completo como archivo ZIP
  /// Incluye: datos JSON + carpeta de imágenes
  /// Retorna true si se compartió exitosamente
  Future<bool> exportarCatalogo() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fotosDir = await _fotosDir;

      // Crear archivo ZIP
      final archive = Archive();

      // 1. Convertir plantas a JSON
      final plantasData = _plantasBox.values.map((p) => {
        'id': p.id,
        'nombre': p.nombre,
        'precio': p.precio,
        'categoria': p.categoria,
        'tipoLuz': p.tipoLuz.index,
        'frecuenciaRiego': p.frecuenciaRiego.index,
        'fotoPath': p.fotoPath.isNotEmpty ? p.fotoPath.split('/').last : '',
        'createdAt': p.createdAt.toIso8601String(),
      }).toList();

      final jsonString = jsonEncode(plantasData);
      final jsonBytes = utf8.encode(jsonString);
      
      archive.addFile(ArchiveFile(
        'catalogo.json',
        jsonBytes.length,
        jsonBytes,
      ));

      // 2. Agregar todas las fotos al ZIP
      if (await fotosDir.exists()) {
        await for (final entity in fotosDir.list()) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            final fileName = entity.path.split(Platform.pathSeparator).last;
            archive.addFile(ArchiveFile(
              'fotos/$fileName',
              bytes.length,
              bytes,
            ));
          }
        }
      }

      // 3. Codificar y guardar ZIP
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) return false;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipPath = '${tempDir.path}/vivero_catalogo_$timestamp.zip';
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);

      // 4. Compartir archivo via share_plus
      final result = await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Catálogo Vivero de Plantas',
        text: 'Catálogo exportado el ${DateTime.now().toString().substring(0, 16)}',
      );

      return result.status == ShareResultStatus.success || 
             result.status == ShareResultStatus.dismissed;
    } catch (e) {
      // ignore: avoid_print
      print('Error exportando catálogo: $e');
      return false;
    }
  }

  /// Importa un catálogo desde archivo ZIP
  /// ADVERTENCIA: Sobrescribe todos los datos actuales
  /// Retorna el número de plantas importadas, o -1 si hay error
  Future<int> importarCatalogo() async {
    try {
      // 1. Seleccionar archivo ZIP
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: 'Seleccionar catálogo ZIP',
      );

      if (result == null || result.files.isEmpty) return 0;

      final filePath = result.files.first.path;
      if (filePath == null) return -1;

      // 2. Leer y decodificar ZIP
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 3. Buscar archivo de datos
      ArchiveFile? catalogoFile;
      for (final file in archive) {
        if (file.name == 'catalogo.json') {
          catalogoFile = file;
          break;
        }
      }

      if (catalogoFile == null) return -1;

      // 4. Parsear JSON
      final jsonString = utf8.decode(catalogoFile.content as List<int>);
      final List<dynamic> plantasData = jsonDecode(jsonString);

      // 5. Preparar directorio de fotos
      final fotosDir = await _fotosDir;
      if (!await fotosDir.exists()) {
        await fotosDir.create(recursive: true);
      }

      // 6. Extraer fotos
      for (final file in archive) {
        if (file.name.startsWith('fotos/') && file.isFile) {
          final fileName = file.name.replaceFirst('fotos/', '');
          if (fileName.isNotEmpty) {
            final outFile = File('${fotosDir.path}/$fileName');
            await outFile.writeAsBytes(file.content as List<int>);
          }
        }
      }

      // 7. Limpiar datos actuales
      await _plantasBox.clear();

      // 8. Importar plantas
      int importadas = 0;
      for (final data in plantasData) {
        final fotoFileName = data['fotoPath'] as String? ?? '';
        final fotoPath = fotoFileName.isNotEmpty 
            ? '${fotosDir.path}/$fotoFileName' 
            : '';

        final planta = Planta()
          ..id = data['id'] as String
          ..nombre = data['nombre'] as String
          ..precio = (data['precio'] as num).toDouble()
          ..categoria = data['categoria'] as String
          ..tipoLuz = TipoLuz.values[data['tipoLuz'] as int]
          ..frecuenciaRiego = FrecuenciaRiego.values[data['frecuenciaRiego'] as int]
          ..fotoPath = fotoPath
          ..createdAt = DateTime.parse(data['createdAt'] as String);

        await _plantasBox.add(planta);
        importadas++;
      }

      return importadas;
    } catch (e) {
      // ignore: avoid_print
      print('Error importando catálogo: $e');
      return -1;
    }
  }

  /// Obtiene estadísticas del catálogo actual
  Future<Map<String, dynamic>> getStats() async {
    final fotosDir = await _fotosDir;
    int fotosSize = 0;
    int fotosCount = 0;

    if (await fotosDir.exists()) {
      await for (final entity in fotosDir.list()) {
        if (entity is File) {
          fotosSize += await entity.length();
          fotosCount++;
        }
      }
    }

    return {
      'plantasCount': _plantasBox.length,
      'fotosCount': fotosCount,
      'fotosSize': fotosSize,
      'fotosSizeFormatted': _formatBytes(fotosSize),
    };
  }

  /// Formatea bytes a string legible
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Limpia todos los datos (plantas + fotos)
  Future<void> limpiarTodo() async {
    await _plantasBox.clear();
    
    final fotosDir = await _fotosDir;
    if (await fotosDir.exists()) {
      await fotosDir.delete(recursive: true);
    }
  }
}
