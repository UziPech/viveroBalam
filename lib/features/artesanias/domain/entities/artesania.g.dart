// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artesania.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtesaniaAdapter extends TypeAdapter<Artesania> {
  @override
  final int typeId = 3;

  @override
  Artesania read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artesania()
      ..id = fields[0] as String
      ..nombre = fields[1] as String
      ..precio = fields[2] as double
      ..ancho = fields[3] as double
      ..alto = fields[4] as double
      ..descripcion = fields[5] as String
      ..fotoPath = fields[6] as String
      ..categoria = fields[7] as String
      ..createdAt = fields[8] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Artesania obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.precio)
      ..writeByte(3)
      ..write(obj.ancho)
      ..writeByte(4)
      ..write(obj.alto)
      ..writeByte(5)
      ..write(obj.descripcion)
      ..writeByte(6)
      ..write(obj.fotoPath)
      ..writeByte(7)
      ..write(obj.categoria)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtesaniaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
