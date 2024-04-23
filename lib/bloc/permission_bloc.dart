import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/permission_model.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  PermissionsBloc() : super(PermissionsInitial()) {
    on<PermissionsStatusRequested>((event, emit) async {
      emit(PermissionsProgress());
      try {
        permissionDetails[0].status = await Permission.camera.status == PermissionStatus.granted;
        permissionDetails[1].status = await Permission.location.status == PermissionStatus.granted;
        permissionDetails[2].status = await Permission.storage.status == PermissionStatus.granted;
        permissionDetails[3].status = await Permission.microphone.status == PermissionStatus.granted;
        emit(PermissionsSuccess(permissionDetails: permissionDetails));
      } catch (e) {
        log(e.toString());
        emit(PermissionsFailure());
      }
    });
  }
}

// event  -- inst
abstract class PermissionsEvent {}

//state -- inst
abstract class PermissionsState {}

///event impl
class PermissionsStatusRequested extends PermissionsEvent {}

//state impl
class PermissionsInitial extends PermissionsState {}

class PermissionsProgress extends PermissionsState {}

class PermissionsSuccess extends PermissionsState {
  final List<PermissionDetail> permissionDetails;

  PermissionsSuccess({required this.permissionDetails});
}

class PermissionsFailure extends PermissionsState {}
