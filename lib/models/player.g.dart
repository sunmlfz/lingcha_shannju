// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SixSensesAdapter extends TypeAdapter<SixSenses> {
  @override
  final int typeId = 4;

  @override
  SixSenses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SixSenses(
      eye: fields[0] as double,
      ear: fields[1] as double,
      nose: fields[2] as double,
      tongue: fields[3] as double,
      body: fields[4] as double,
      mind: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SixSenses obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.eye)
      ..writeByte(1)
      ..write(obj.ear)
      ..writeByte(2)
      ..write(obj.nose)
      ..writeByte(3)
      ..write(obj.tongue)
      ..writeByte(4)
      ..write(obj.body)
      ..writeByte(5)
      ..write(obj.mind);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SixSensesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeaInventoryItemAdapter extends TypeAdapter<TeaInventoryItem> {
  @override
  final int typeId = 5;

  @override
  TeaInventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeaInventoryItem(
      variety: fields[0] as TeaVariety,
      quality: fields[1] as TeaQuality,
      quantity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TeaInventoryItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.variety)
      ..writeByte(1)
      ..write(obj.quality)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeaInventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 6;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      name: fields[0] as String,
      teaLeaves: fields[1] as int,
      teaCoins: fields[2] as int,
      senses: fields[3] as SixSenses,
      inventory: (fields[4] as List).cast<TeaInventoryItem>(),
      level: fields[5] as int,
      experience: fields[6] as int,
      lastSaveMs: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.teaLeaves)
      ..writeByte(2)
      ..write(obj.teaCoins)
      ..writeByte(3)
      ..write(obj.senses)
      ..writeByte(4)
      ..write(obj.inventory)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.experience)
      ..writeByte(7)
      ..write(obj.lastSaveMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
