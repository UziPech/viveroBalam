// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sustrato.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SustratoAdapter extends TypeAdapter<Sustrato> {
  @override
  final int typeId = 4;

  @override
  Sustrato read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sustrato()
      ..id = fields[0] as String
      ..nombre = fields[1] as String
      ..precio = fields[2] as double
      ..cantidad = fields[3] as int
      ..descripcion = fields[4] as String
      ..fotoPath = fields[5] as String
      ..categoria = fields[6] as String
      ..createdAt = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Sustrato obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.precio)
      ..writeByte(3)
      ..write(obj.cantidad)
      ..writeByte(4)
      ..write(obj.descripcion)
      ..writeByte(5)
      ..write(obj.fotoPath)
      ..writeByte(6)
      ..write(obj.categoria)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SustratoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
