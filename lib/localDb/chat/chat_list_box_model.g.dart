// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_box_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatListBoxModelAdapter extends TypeAdapter<ChatListBoxModel> {
  @override
  final int typeId = 6;

  @override
  ChatListBoxModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatListBoxModel(
      chatRoomModel: fields[0] as ChatRoomModel?,
      targetUser: fields[1] as UserModel?,
      lastMssg: fields[2] as String?,
      chatsModel: fields[3] as ChatsModel?,
      time: fields[4] as Timestamp?,
      isMessageRead: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatListBoxModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.chatRoomModel)
      ..writeByte(1)
      ..write(obj.targetUser)
      ..writeByte(2)
      ..write(obj.lastMssg)
      ..writeByte(3)
      ..write(obj.chatsModel)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.isMessageRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatListBoxModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
