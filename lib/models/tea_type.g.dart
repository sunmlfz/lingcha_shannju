// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tea_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeaQualityAdapter extends TypeAdapter<TeaQuality> {
  @override
  final int typeId = 0;

  @override
  TeaQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TeaQuality.crude;
      case 1:
        return TeaQuality.common;
      case 2:
        return TeaQuality.fine;
      case 3:
        return TeaQuality.superior;
      case 4:
        return TeaQuality.masterwork;
      default:
        return TeaQuality.crude;
    }
  }

  @override
  void write(BinaryWriter writer, TeaQuality obj) {
    switch (obj) {
      case TeaQuality.crude:
        writer.writeByte(0);
        break;
      case TeaQuality.common:
        writer.writeByte(1);
        break;
      case TeaQuality.fine:
        writer.writeByte(2);
        break;
      case TeaQuality.superior:
        writer.writeByte(3);
        break;
      case TeaQuality.masterwork:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeaQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeaVarietyAdapter extends TypeAdapter<TeaVariety> {
  @override
  final int typeId = 1;

  @override
  TeaVariety read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TeaVariety.lvcha;
      case 1:
        return TeaVariety.hongcha;
      case 2:
        return TeaVariety.wulong;
      case 3:
        return TeaVariety.baihao;
      case 4:
        return TeaVariety.puer;
      case 5:
        return TeaVariety.huangcha;
      default:
        return TeaVariety.lvcha;
    }
  }

  @override
  void write(BinaryWriter writer, TeaVariety obj) {
    switch (obj) {
      case TeaVariety.lvcha:
        writer.writeByte(0);
        break;
      case TeaVariety.hongcha:
        writer.writeByte(1);
        break;
      case TeaVariety.wulong:
        writer.writeByte(2);
        break;
      case TeaVariety.baihao:
        writer.writeByte(3);
        break;
      case TeaVariety.puer:
        writer.writeByte(4);
        break;
      case TeaVariety.huangcha:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeaVarietyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
