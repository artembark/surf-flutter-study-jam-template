import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';

import '../../exceptions/auth_exception.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(const AuthState());

  void login(String login, String password) async {
    if (login.isEmpty || password.isEmpty) {
      emit(const AuthState(
          errorMessage: 'Поля логин и пароль не могут быть пустыми'));
      return;
    }

    emit(const AuthState(loading: true));
    await authRepository
        .signIn(login: login, password: password)
        .then((tokenDto) => emit(AuthState(tokenDto: tokenDto)))
        //обработка ошибка неверно заданного логина и пароля, определяется по
        //типу кастомного исключения
        .catchError((Object error) {
      final exception = error as AuthException;
      emit(AuthState(errorMessage: exception.message));
    }, test: (error) => error is AuthException).
        //обработка всех остальных ошибок и вывод типа ошибки и стектрейс
        //для облегчения поиска проблемы во время отладки
        catchError((Object error, StackTrace stackTrace) {
      if (kDebugMode) {
        print(error.toString());
        print(stackTrace);
      }
      emit(const AuthState(errorMessage: 'Неизвестная ошибка'));
    });

    final TokenDto token =
        await authRepository.signIn(login: login, password: password);
    emit(AuthState(tokenDto: token));
  }
}
