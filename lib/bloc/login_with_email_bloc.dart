import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/auth_services.dart';

class EmailAuthBloc extends Bloc<EmailAuthEvent, EmailAuthState> {
  EmailAuthBloc() : super(EmailAuthInitial()) {
    on<LoginUsingEmail>((event, emit) async {
      emit(EmailAuthProgress());
      try {
        UserCredential? authResult = await auth.signInUsingEmail(event.email, event.password);
        if (authResult != null) {
          debugPrint("authResult: $authResult");
          emit(EmailAuthSuccess(authResult));
        } else {
          emit(EmailAuthFailure("Unable to authenticate ${event.email}"));
        }
      } catch (e) {
        emit(EmailAuthFailure(e.toString()));
      }
    });
  }

  final AuthenticationService auth = AuthenticationService();
}

//event
abstract class EmailAuthEvent {}

//state
abstract class EmailAuthState {}

//event impl
class LoginUsingEmail extends EmailAuthEvent {
  final String email;
  final String password;
  LoginUsingEmail({
    required this.email,
    required this.password,
  });
}

//states impl
class EmailAuthInitial extends EmailAuthState {}

class EmailAuthProgress extends EmailAuthState {}

class EmailAuthSuccess extends EmailAuthState {
  final UserCredential? authResult;
  EmailAuthSuccess(this.authResult);
}

class EmailAuthFailure extends EmailAuthState {
  final String error;
  EmailAuthFailure(this.error);
}
