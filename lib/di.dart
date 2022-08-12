import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/blocs/auth_cubit/auth_cubit.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/blocs/image_upload_cubit.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/datasource/image_upload_data_source.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/repository/image_upload_repository.dart';
import 'package:surf_practice_chat_flutter/features/location/blocs/location_cubit.dart';
import 'package:surf_practice_chat_flutter/features/location/datasource/geolocator_data_source.dart';
import 'package:surf_practice_chat_flutter/features/location/repository/geolocation_repository.dart';
import 'package:surf_practice_chat_flutter/features/settings/blocs/app_settings/app_settings_cubit.dart';
import 'package:surf_practice_chat_flutter/features/topics/blocs/topics/topics_cubit.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chart_topics_repository.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import 'features/chat/blocs/chat_cubit/chat_cubit.dart';

final GetIt locator = GetIt.instance;

///Конфигурирование зависимостей
Future<void> initializeDependencies() async {
  //для сохранения в настройки
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => sharedPreferences);

  //Bloc/Cubit
  //Кубит состояния авторизации
  locator.registerFactory(
    () => AuthCubit(authRepository: locator()),
  );
  //Кубит тем
  locator.registerFactory(
    () => TopicsCubit(chatTopicsRepository: locator()),
  );
  //Кубит состояния чата
  locator.registerFactory(
    () => ChatCubit(chatRepository: locator()),
  );
  //Кубит геолокации
  locator.registerFactory(
    () => LocationCubit(geolocationRepository: locator()),
  );
  //Кубит загрузки файла
  locator.registerFactory(
    () => ImageUploadCubit(imageUploadRepository: locator()),
  );
  //Кубит настроек приложения
  locator.registerFactory(
    () => AppSettingsCubit(sharedPreferences: locator()),
  );

  //тут бы по-другому)
  final String token = sharedPreferences.getString('token') ?? '';
  StudyJamClient studyJamClient = StudyJamClient();
  if (token.isNotEmpty) {
    studyJamClient = StudyJamClient().getAuthorizedClient(token);
    await studyJamClient.getUser().then((value) {}).catchError((error) {
      sharedPreferences.setString('token', '');
    });
  }

  //Репозитории
  //Репозиторий авторизации
  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(studyJamClient),
  );
  //Репозиторий чата
  locator.registerLazySingleton<IChatRepository>(
    () => ChatRepository(studyJamClient),
  );
  //Репозиторий тем
  locator.registerLazySingleton<IChatTopicsRepository>(
    () => ChatTopicsRepository(studyJamClient),
  );

  //Репозиторий геолокации
  locator.registerLazySingleton<GeolocationRepository>(
    () => GeolocationRepositoryImpl(locationDataSource: locator()),
  );
  //Репозиторий загрузки изображений
  locator.registerLazySingleton<ImageUploadRepository>(
    () => ImageUploadRepositoryImpl(imageUploadDataSource: locator()),
  );

  //источник данных геолокации
  locator.registerLazySingleton<LocationDataSource>(
    () => GeolocatorDataSource(),
  );
  //источник данных загрузки изображений
  locator.registerLazySingleton<ImageUploadDataSource>(
    () => FreeImageUploadDataSource(client: locator()),
  );

  //Внешние зависимости
  //http-клиент для запросов
  locator.registerLazySingleton(() => http.Client());
}
