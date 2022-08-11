import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/common/app_theme.dart';
import 'package:surf_practice_chat_flutter/features/auth/screens/auth_screen.dart';
import 'package:surf_practice_chat_flutter/features/location/blocs/location_cubit.dart';
import 'package:surf_practice_chat_flutter/features/settings/blocs/app_settings/app_settings_cubit.dart';

import 'common/app_bloc_observer.dart';
import 'di.dart';
import 'features/auth/blocs/auth_cubit/auth_cubit.dart';

void main() async {
  //инициализация биндингов
  WidgetsFlutterBinding.ensureInitialized();

  //инициализация зависимостей
  await initializeDependencies();

  //блокировка отображения в горизонтальном режиме
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //запуск приложения и передача стартовой страницы параметорм
  BlocOverrides.runZoned(() => runApp(const SurfChatApp()),
      //для логгирования событий bloc
      blocObserver: AppBlocObserver());
}

/// App,s main widget.
class SurfChatApp extends StatelessWidget {
  /// Constructor for [SurfChatApp].
  const SurfChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator.get<AuthCubit>()),
        BlocProvider(create: (_) => locator.get<AppSettingsCubit>()),
        BlocProvider(create: (_) => locator.get<LocationCubit>()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AuthScreen(),
      ),
    );
  }
}
