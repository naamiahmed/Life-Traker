// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SectorModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectorModelAdapter extends TypeAdapter<SectorModel> {
  @override
  final int typeId = 2;

  @override
  SectorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SectorModel(
      name: fields[0] as String,
      iconName: fields[1] as String,
      colorName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SectorModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.iconName)
      ..writeByte(2)
      ..write(obj.colorName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
