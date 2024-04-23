import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetectFirebaseUserChangesBloc extends Bloc<DetectFirebaseUserChangesEvent, DetectFirebaseUserChangesState> {
  DetectFirebaseUserChangesBloc() : super(DetectFirebaseUserChangesInitial()) {
    FirebaseAuth auth = FirebaseAuth.instance;
    on<StartFirebaseUserChangeListener>((event, emit) async {
      if (kDebugMode) debugPrint('Called DetectFirebaseUserChangesBloc');
      emit(DetectFirebaseUserChangesProgress());
      await emit.forEach(auth.userChanges(), onData: ((User? user) {
        if (kDebugMode) debugPrint('DetectFirebaseUserChangesBloc >> StartFirebaseUserChangeListener >> User Changed >> $user');
        if (user != null) {
          return DetectFirebaseUserChangesSuccess(user);
        } else {
          return DetectFirebaseUserChangesFailure();
        }
      }), onError: (error, stackTrace) {
        if (kDebugMode) {
          debugPrint("detect firebase auth user change stream - $error");
        }
        return DetectFirebaseUserChangesFailure();
      });
    });
  }
}

//states
abstract class DetectFirebaseUserChangesState {}

//events
abstract class DetectFirebaseUserChangesEvent {}

//states implementation
class DetectFirebaseUserChangesInitial extends DetectFirebaseUserChangesState {}

class DetectFirebaseUserChangesProgress extends DetectFirebaseUserChangesState {}

class DetectFirebaseUserChangesSuccess extends DetectFirebaseUserChangesState {
  final User user;
  DetectFirebaseUserChangesSuccess(this.user);
}

class DetectFirebaseUserChangesFailure extends DetectFirebaseUserChangesState {}

//events implementation
class StartFirebaseUserChangeListener extends DetectFirebaseUserChangesEvent {}
