part of 'app_settings_cubit.dart';

class AppSettingsState extends Equatable {
  final TokenDto? tokenDto;
  final String? userName;

  const AppSettingsState({this.tokenDto, this.userName});

  AppSettingsState copyWith({TokenDto? tokenDto, String? userName}) =>
      AppSettingsState(
        tokenDto: tokenDto ?? this.tokenDto,
        userName: userName ?? this.userName,
      );

  @override
  List<Object?> get props => [tokenDto, userName];
}
