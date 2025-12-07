import 'package:hive/hive.dart';

part 'categoria.g.dart';

/// Entidad: Categoría (para clasificar productos)
@HiveType(typeId: 5)
class Categoria extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nombre;

  @HiveField(2)
  late String tipo; // 'planta', 'artesania', 'sustrato'

  /// Constructor vacío requerido por Hive
  Categoria();

  /// Constructor de conveniencia
  Categoria.create({
    String? id,
    required String nombre,
    required String tipo,
  }) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    this.nombre = nombre;
    this.tipo = tipo;
  }

  /// Tipos disponibles
  static const List<String> tipos = ['planta', 'artesania', 'sustrato'];

  /// Categorías predefinidas por tipo
  static List<String> getPredefinidas(String tipo) {
    switch (tipo) {
      case 'planta':
        return ['Suculenta', 'Floral', 'Árbol', 'Frutal', 'Maceta', 'Sombra', 'Ornamental', 'Cactus'];
      case 'artesania':
        return ['Decoración', 'Macetas', 'Figuras', 'Jardinería', 'Herramientas'];
      case 'sustrato':
        return ['Tierra', 'Abono', 'Fertilizante', 'Piedras', 'Composta'];
      default:
        return ['General'];
    }
  }
}
