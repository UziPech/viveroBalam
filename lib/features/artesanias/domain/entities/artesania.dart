import 'package:hive/hive.dart';

part 'artesania.g.dart';

/// Entidad: Artesanía (productos decorativos)
@HiveType(typeId: 3)
class Artesania extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nombre;

  @HiveField(2)
  late double precio;

  @HiveField(3)
  late double ancho; // cm

  @HiveField(4)
  late double alto; // cm

  @HiveField(5)
  late String descripcion;

  @HiveField(6)
  late String fotoPath;

  @HiveField(7)
  late String categoria;

  @HiveField(8)
  late DateTime createdAt;

  /// Constructor vacío requerido por Hive
  Artesania();

  /// Constructor de conveniencia
  Artesania.create({
    String? id,
    required String nombre,
    required double precio,
    required double ancho,
    required double alto,
    String descripcion = '',
    String fotoPath = '',
    String categoria = 'General',
    DateTime? createdAt,
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.nombre = nombre;
    this.precio = precio;
    this.ancho = ancho;
    this.alto = alto;
    this.descripcion = descripcion;
    this.fotoPath = fotoPath;
    this.categoria = categoria;
    this.createdAt = createdAt ?? DateTime.now();
  }

  /// Dimensiones formateadas (ancho × alto cm)
  String get dimensiones => '${ancho.toStringAsFixed(0)} × ${alto.toStringAsFixed(0)} cm';
}
