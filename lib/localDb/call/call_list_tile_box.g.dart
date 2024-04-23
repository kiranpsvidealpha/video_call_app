// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_list_tile_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallListTileBoxAdapter extends TypeAdapter<CallListTileBox> {
  @override
  final int typeId = 7;

  @override
  CallListTileBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallListTileBox(
      index: fields[0] as int?,
      docId: fields[1] as String?,
      title: fields[2] as String?,
      caller: fields[3] as String?,
      wasMissed: fields[4] as bool?,
      isAudioCall: fields[5] as bool?,
      timestamp: fields[6] as Timestamp?,
      context: fields[7] as BuildContext?,
      profileImage: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CallListTileBox obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.index)
      ..writeByte(1)
      ..write(obj.docId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.caller)
      ..writeByte(4)
      ..write(obj.wasMissed)
      ..writeByte(5)
      ..write(obj.isAudioCall)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.context)
      ..writeByte(8)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallListTileBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
