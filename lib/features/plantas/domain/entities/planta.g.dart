// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantaAdapter extends TypeAdapter<Planta> {
  @override
  final int typeId = 0;

  @override
  Planta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Planta()
      ..id = fields[0] as String
      ..nombre = fields[1] as String
      ..precio = fields[2] as double
      ..categoria = fields[3] as String
      ..tipoLuz = fields[4] as TipoLuz
      ..frecuenciaRiego = fields[5] as FrecuenciaRiego
      ..fotoPath = fields[6] as String
      ..createdAt = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Planta obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.precio)
      ..writeByte(3)
      ..write(obj.categoria)
      ..writeByte(4)
      ..write(obj.tipoLuz)
      ..writeByte(5)
      ..write(obj.frecuenciaRiego)
      ..writeByte(6)
      ..write(obj.fotoPath)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipoLuzAdapter extends TypeAdapter<TipoLuz> {
  @override
  final int typeId = 1;

  @override
  TipoLuz read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoLuz.sol;
      case 1:
        return TipoLuz.sombra;
      case 2:
        return TipoLuz.mediaSombra;
      default:
        return TipoLuz.sol;
    }
  }

  @override
  void write(BinaryWriter writer, TipoLuz obj) {
    switch (obj) {
      case TipoLuz.sol:
        writer.writeByte(0);
        break;
      case TipoLuz.sombra:
        writer.writeByte(1);
        break;
      case TipoLuz.mediaSombra:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoLuzAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FrecuenciaRiegoAdapter extends TypeAdapter<FrecuenciaRiego> {
  @override
  final int typeId = 2;

  @override
  FrecuenciaRiego read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FrecuenciaRiego.diario;
      case 1:
        return FrecuenciaRiego.cadaDosDias;
      case 2:
        return FrecuenciaRiego.semanal;
      case 3:
        return FrecuenciaRiego.quincenal;
      default:
        return FrecuenciaRiego.diario;
    }
  }

  @override
  void write(BinaryWriter writer, FrecuenciaRiego obj) {
    switch (obj) {
      case FrecuenciaRiego.diario:
        writer.writeByte(0);
        break;
      case FrecuenciaRiego.cadaDosDias:
        writer.writeByte(1);
        break;
      case FrecuenciaRiego.semanal:
        writer.writeByte(2);
        break;
      case FrecuenciaRiego.quincenal:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrecuenciaRiegoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
