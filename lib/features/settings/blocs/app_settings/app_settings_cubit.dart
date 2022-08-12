import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';

part 'app_settings_state.dart';

///кубит для сохранения и доступу к хранилищу SharedPreferences
class AppSettingsCubit extends Cubit<AppSettingsState> {
  //объект доступа к хранилищу sharedPreferences передается зависимостью
  final SharedPreferences sharedPreferences;
  final String tokenKey = 'token';
  final String userNameKey = 'userName';

  //конструктор с обязательным именованым параметром объекта доступа к хранилищу
  AppSettingsCubit({required this.sharedPreferences})
      : super(const AppSettingsState());

  //метод сохранения токена в хранилище
  Future<void> saveToken(TokenDto tokenDto) async {
    //записываем в случае смены названия
    if (tokenDto != state.tokenDto) {
      //запись токена по ключу в хранилище, асинхронная
      await sharedPreferences.setString(tokenKey, tokenDto.token);
      //выбрасывание обновленного состояние с новым токеном
      emit(state.copyWith(tokenDto: tokenDto));
    }
  }

  //метод получения сохраненного токена из хранилища
  String getToken() {
    //чтение токена из хранилища по ключу
    //в случае отсутствия ключа считывается пустая строка
    final String token = sharedPreferences.getString(tokenKey) ?? '';
    //выбрасывание обновленного состояние с полученным названием токена
    emit(state.copyWith(tokenDto: TokenDto(token: token)));
    //возвращаемое значение
    return token;
  }

  //метод сохранения имени пользователя в хранилище
  Future<void> saveUserName(String userName) async {
    //записываем в случае смены названия
    if (userName != state.userName) {
      //запись токена по ключу в хранилище, асинхронная
      await sharedPreferences.setString(userNameKey, userName);
      //выбрасывание обновленного состояние с новым токеном
      emit(state.copyWith(userName: userName));
    }
  }

  //метод получения сохраненного имени пользователя из хранилища
  String getUserName() {
    //чтение токена из хранилища по ключу
    //в случае отсутствия ключа считывается пустая строка
    final String userName = sharedPreferences.getString(userNameKey) ?? '';
    //выбрасывание обновленного состояние с полученным названием токена
    emit(state.copyWith(userName: userName));
    //возвращаемое значение
    return userName;
  }

  void resetToken() async {
    //запись токена по ключу в хранилище, асинхронная

    await sharedPreferences.setString(tokenKey, '');
    //выбрасывание обновленного состояние с новым токеном
    emit(state.copyWith(tokenDto: const TokenDto(token: '')));
  }
}
