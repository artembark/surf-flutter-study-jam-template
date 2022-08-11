import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/blocs/auth_cubit/auth_cubit.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/location/blocs/location_cubit.dart';
import 'package:surf_practice_chat_flutter/features/location/datasource/geolocator_data_source.dart';
import 'package:surf_practice_chat_flutter/features/location/repository/geolocation_repository.dart';
import 'package:surf_practice_chat_flutter/features/settings/blocs/app_settings/app_settings_cubit.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import 'features/chat/blocs/chat_cubit/chat_cubit.dart';

final GetIt locator = GetIt.instance;

///Конфигурирование зависимостей
Future<void> initializeDependencies() async {
  //Bloc/Cubit
  //Кубит состояния авторизации
  locator.registerFactory(
    () => AuthCubit(authRepository: locator()),
  );
  //Кубит состояния чата
  locator.registerFactory(
    () => ChatCubit(chatRepository: locator()),
  );
  //Кубит геолокации
  locator.registerFactory(
    () => LocationCubit(geolocationRepository: locator()),
  );
  //Кубит настроек приложения
  locator.registerFactory(
    () => AppSettingsCubit(sharedPreferences: locator()),
  );

  final StudyJamClient studyJamClient = StudyJamClient();

  //Репозитории
  //Репозиторий авторизации
  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(studyJamClient),
  );
  //Репозиторий чата
  locator.registerLazySingleton<IChatRepository>(
    () => ChatRepository(studyJamClient),
  );
  //Репозиторий геолокации
  locator.registerLazySingleton<GeolocationRepository>(
    () => GeolocationRepositoryImpl(locationDataSource: locator()),
  );

  //источник данных геолокации
  locator.registerLazySingleton<LocationDataSource>(
    () => GeolocatorDataSource(),
  );

  //для сохранения в настройки
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => sharedPreferences);
}
