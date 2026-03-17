// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processing_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProcessingStateAdapter extends TypeAdapter<ProcessingState> {
  @override
  final int typeId = 7;

  @override
  ProcessingState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProcessingState.idle;
      case 1:
        return ProcessingState.processing;
      case 2:
        return ProcessingState.done;
      default:
        return ProcessingState.idle;
    }
  }

  @override
  void write(BinaryWriter writer, ProcessingState obj) {
    switch (obj) {
      case ProcessingState.idle:
        writer.writeByte(0);
        break;
      case ProcessingState.processing:
        writer.writeByte(1);
        break;
      case ProcessingState.done:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProcessingTaskAdapter extends TypeAdapter<ProcessingTask> {
  @override
  final int typeId = 8;

  @override
  ProcessingTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessingTask(
      id: fields[0] as String,
      variety: fields[1] as TeaVariety,
      inputLeaves: fields[2] as int,
      state: fields[3] as ProcessingState,
      startedAtMs: fields[4] as int,
      durationMs: fields[5] as int,
      resultQuality: fields[6] as TeaQuality,
      resultQuantity: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProcessingTask obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.variety)
      ..writeByte(2)
      ..write(obj.inputLeaves)
      ..writeByte(3)
      ..write(obj.state)
      ..writeByte(4)
      ..write(obj.startedAtMs)
      ..writeByte(5)
      ..write(obj.durationMs)
      ..writeByte(6)
      ..write(obj.resultQuality)
      ..writeByte(7)
      ..write(obj.resultQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
