part of 'app_settings_cubit.dart';

//состояния кубита для сохранения выбранного города в хранилище
//расширение от Equatable для возможности сравнивать состояния
class AppSettingsState extends Equatable {
  final String? token;

  const AppSettingsState({this.token});

  @override
  List<Object?> get props => [token];
}
