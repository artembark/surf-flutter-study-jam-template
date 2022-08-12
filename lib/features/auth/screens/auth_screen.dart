import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/blocs/auth_cubit/auth_cubit.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/settings/blocs/app_settings/app_settings_cubit.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import '../../topics/repository/chart_topics_repository.dart';
import '../../topics/screens/topics_screen.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Constructor for [AuthScreen].
  const AuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //контроллер для доступа к текстовому полю
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  //текст ошибки поля для ввода
  String errorText = '';

  @override
  void initState() {
    loginController.text = 'artembark';
    passController.text = 'hpE0xR7aDItA';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        final TokenDto? token = state.tokenDto;
        if (token != null) {
          context.read<AppSettingsCubit>().saveToken(token);
          _pushToTopics(context, token);
        }
        final String? errorMessage = state.errorMessage;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.dangerous_rounded,
                  color: Colors.red,
                ),
                Expanded(
                  child: Text(
                    errorMessage,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ));
        }
      },
      listenWhen: (previous, current) {
        return previous.tokenDto != current.tokenDto ||
            previous.errorMessage != current.errorMessage;
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Padding(
              //настройка отступа
              padding: const EdgeInsets.all(16.0),
              //поле для ввода названия города
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    //назначается контроллер
                    controller: loginController,
                    //включается текстовая клавиатура
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Логин',
                      //пустой helperText для предотвращения смещения виджетов при появдении ошибки
                      helperText: ' ',
                      //проверяется наличие текста ошибки
                      errorText: (errorText == '') ? null : errorText,
                      prefixIcon: const Icon(Icons.person),
                      //отображение иконки для очистки текстового поля
                      suffixIcon: IconButton(
                        onPressed: loginController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                      //включение внешней рамки
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    //валидация данных по мере ввода
                  ),
                  TextField(
                    //назначается контроллер
                    controller: passController,
                    //включается текстовая клавиатура
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      //пустой helperText для предотвращения смещения виджетов при появдении ошибки
                      helperText: ' ',
                      //проверяется наличие текста ошибки
                      errorText: (errorText == '') ? null : errorText,
                      prefixIcon: const Icon(Icons.lock),
                      //отображение иконки для очистки текстового поля
                      suffixIcon: IconButton(
                        onPressed: passController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                      //включение внешней рамки
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context
                            .read<AuthCubit>()
                            .login(loginController.text, passController.text);
                      },
                      child: const Text('ДАЛЕЕ')),
                  if (state.loading) const LinearProgressIndicator()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pushToTopics(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return TopicsScreen(
            chatTopicsRepository: ChatTopicsRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }
}
