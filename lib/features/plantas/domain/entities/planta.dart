import 'package:hive/hive.dart';

part 'planta.g.dart';

/// Tipos de luz que requiere la planta
@HiveType(typeId: 1)
enum TipoLuz {
  @HiveField(0)
  sol,
  @HiveField(1)
  sombra,
  @HiveField(2)
  mediaSombra,
}

/// Frecuencia de riego requerida
@HiveType(typeId: 2)
enum FrecuenciaRiego {
  @HiveField(0)
  diario,
  @HiveField(1)
  cadaDosDias,
  @HiveField(2)
  semanal,
  @HiveField(3)
  quincenal,
}

/// Entidad principal: Planta
@HiveType(typeId: 0)
class Planta extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nombre;

  @HiveField(2)
  late double precio;

  @HiveField(3)
  late String categoria; // Suculenta, Frutal, Sombra, Floral, Árbol

  @HiveField(4)
  late TipoLuz tipoLuz;

  @HiveField(5)
  late FrecuenciaRiego frecuenciaRiego;

  @HiveField(6)
  late String fotoPath; // Ruta local del archivo .jpg

  @HiveField(7)
  late DateTime createdAt;

  /// Constructor vacío requerido por Hive
  Planta();

  /// Constructor de conveniencia para crear nuevas plantas
  Planta.create({
    String? id,
    required String nombre,
    required double precio,
    required String categoria,
    required TipoLuz tipoLuz,
    required FrecuenciaRiego frecuenciaRiego,
    String fotoPath = '',
    DateTime? createdAt,
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.nombre = nombre;
    this.precio = precio;
    this.categoria = categoria;
    this.tipoLuz = tipoLuz;
    this.frecuenciaRiego = frecuenciaRiego;
    this.fotoPath = fotoPath;
    this.createdAt = createdAt ?? DateTime.now();
  }

  /// Helper para obtener emoji de luz
  String get luzEmoji {
    switch (tipoLuz) {
      case TipoLuz.sol:
        return '☀️';
      case TipoLuz.sombra:
        return '☁️';
      case TipoLuz.mediaSombra:
        return '⛅';
    }
  }

  /// Helper para obtener emoji de riego
  String get riegoEmoji {
    switch (frecuenciaRiego) {
      case FrecuenciaRiego.diario:
        return '💧';
      case FrecuenciaRiego.cadaDosDias:
        return '💧';
      case FrecuenciaRiego.semanal:
        return '💧💧';
      case FrecuenciaRiego.quincenal:
        return '💧💧💧';
    }
  }

  /// Helper para obtener texto de luz
  String get luzTexto {
    switch (tipoLuz) {
      case TipoLuz.sol:
        return 'Sol directo';
      case TipoLuz.sombra:
        return 'Sombra';
      case TipoLuz.mediaSombra:
        return 'Media sombra';
    }
  }

  /// Helper para obtener texto de riego
  String get riegoTexto {
    switch (frecuenciaRiego) {
      case FrecuenciaRiego.diario:
        return 'Riego diario';
      case FrecuenciaRiego.cadaDosDias:
        return 'Cada 2 días';
      case FrecuenciaRiego.semanal:
        return 'Semanal';
      case FrecuenciaRiego.quincenal:
        return 'Quincenal';
    }
  }
}
