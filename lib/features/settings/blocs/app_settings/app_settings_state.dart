part of 'app_settings_cubit.dart';

class AppSettingsState extends Equatable {
  final TokenDto? tokenDto;

  const AppSettingsState({this.tokenDto});

  @override
  List<Object?> get props => [tokenDto];
}
