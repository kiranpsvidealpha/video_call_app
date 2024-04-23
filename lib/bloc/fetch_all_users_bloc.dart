import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../services/firebase_collection.dart';

class FetchAllUsersBloc extends Bloc<FetchAllUsersEvent, FetchAllUsersState> {
  FetchAllUsersBloc() : super(FetchAllUsersInitial()) {
    on<FetchAllUsers>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchAllUsersBloc');
      emit(FetchAllUsersProgress());
      //checking authentication
      final AuthenticationService auth = AuthenticationService();
      if (auth.currentUser() != null) {
        ///calling backend
        try {
          await emit.forEach(cn.userDb.where("role", isNull: false).snapshots(), onData: ((snapshot) {
            return FetchAllUsersSuccess(snapshot.docs.isNotEmpty ? UserDataList.fromQuery(snapshot).userData : []);
          }), onError: (error, stackTrace) {
            if (kDebugMode) debugPrint('FetchAllUsersBloc >> Bloc Emit Exception >>\nerror:$error \nstack:$stackTrace');
            return FetchAllUsersFailure();
          });
        } catch (e) {
          if (kDebugMode) debugPrint('fetch_all_users_bloc.dart [Try Block Exception]>> \n $e');
          emit(FetchAllUsersFailure());
        }
      } else {
        emit(FetchAllUsersFailure());
      }
    });
  }

  final CollectionNames cn = CollectionNames();
}

///instantiate - event
abstract class FetchAllUsersEvent {}

///instantiate - state
abstract class FetchAllUsersState {}

//states impl
class FetchAllUsersInitial extends FetchAllUsersState {}

class FetchAllUsersProgress extends FetchAllUsersState {}

class FetchAllUsersSuccess extends FetchAllUsersState {
  final List<UserData> users;
  FetchAllUsersSuccess(this.users);
}

class FetchAllUsersFailure extends FetchAllUsersState {}

//events impl
class FetchAllUsers extends FetchAllUsersEvent {}
