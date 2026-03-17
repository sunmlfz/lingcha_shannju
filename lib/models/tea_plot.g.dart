// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tea_plot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlotStateAdapter extends TypeAdapter<PlotState> {
  @override
  final int typeId = 2;

  @override
  PlotState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlotState.empty;
      case 1:
        return PlotState.growing;
      case 2:
        return PlotState.ready;
      default:
        return PlotState.empty;
    }
  }

  @override
  void write(BinaryWriter writer, PlotState obj) {
    switch (obj) {
      case PlotState.empty:
        writer.writeByte(0);
        break;
      case PlotState.growing:
        writer.writeByte(1);
        break;
      case PlotState.ready:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlotStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeaPlotAdapter extends TypeAdapter<TeaPlot> {
  @override
  final int typeId = 3;

  @override
  TeaPlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeaPlot(
      id: fields[0] as int,
      state: fields[1] as PlotState,
      variety: fields[2] as TeaVariety?,
      plantedAtMs: fields[3] as int?,
      growthDurationMs: fields[4] as int?,
      pendingHarvest: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TeaPlot obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.state)
      ..writeByte(2)
      ..write(obj.variety)
      ..writeByte(3)
      ..write(obj.plantedAtMs)
      ..writeByte(4)
      ..write(obj.growthDurationMs)
      ..writeByte(5)
      ..write(obj.pendingHarvest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeaPlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
