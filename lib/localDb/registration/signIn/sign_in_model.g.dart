// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SignInModelAdapter extends TypeAdapter<SignInModel> {
  @override
  final int typeId = 3;

  @override
  SignInModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SignInModel(
      phoneNumber: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SignInModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignInModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
