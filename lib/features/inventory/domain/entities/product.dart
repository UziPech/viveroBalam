import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  late String barcode;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double costPrice; // Precio compra

  @HiveField(3)
  late double salePrice; // Precio venta

  @HiveField(4)
  late int currentStock;

  @HiveField(5)
  late int minStock; // Para alertas

  @HiveField(6)
  late String category;

  @HiveField(7)
  late DateTime createdAt;
}
