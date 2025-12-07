import 'package:hive/hive.dart';

part 'sustrato.g.dart';

/// Entidad: Sustrato (materiales para jardinería)
@HiveType(typeId: 4)
class Sustrato extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nombre;

  @HiveField(2)
  late double precio;

  @HiveField(3)
  late int cantidad; // cantidad en stock

  @HiveField(4)
  late String descripcion;

  @HiveField(5)
  late String fotoPath;

  @HiveField(6)
  late String categoria;

  @HiveField(7)
  late DateTime createdAt;

  /// Constructor vacío requerido por Hive
  Sustrato();

  /// Constructor de conveniencia
  Sustrato.create({
    String? id,
    required String nombre,
    required double precio,
    required int cantidad,
    String descripcion = '',
    String fotoPath = '',
    String categoria = 'General',
    DateTime? createdAt,
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.nombre = nombre;
    this.precio = precio;
    this.cantidad = cantidad;
    this.descripcion = descripcion;
    this.fotoPath = fotoPath;
    this.categoria = categoria;
    this.createdAt = createdAt ?? DateTime.now();
  }

  /// Emoji de stock según cantidad
  String get stockEmoji {
    if (cantidad <= 0) return '❌';
    if (cantidad < 5) return '⚠️';
    return '✅';
  }

  /// Texto de stock
  String get stockTexto {
    if (cantidad <= 0) return 'Agotado';
    if (cantidad < 5) return 'Bajo stock';
    return 'Disponible';
  }
}
