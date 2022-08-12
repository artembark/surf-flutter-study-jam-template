import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surf_practice_chat_flutter/common/app_const.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/blocs/image_upload_cubit.dart';
import 'package:surf_practice_chat_flutter/features/topics/blocs/topics/topics_cubit.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';

import '../models/chat_topic_dto.dart';

/// Screen, that is used for creating new chat topics.
class CreateTopicScreen extends StatefulWidget {
  /// Constructor for [CreateTopicScreen].
  const CreateTopicScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _topicNameController = TextEditingController();
  final _topicDescriptionController = TextEditingController();
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.inversePrimary,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: _ChatAppBar(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                //назначается контроллер
                controller: _topicNameController,
                //включается текстовая клавиатура
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Название темы',
                  //пустой helperText для предотвращения смещения виджетов при появдении ошибки
                  helperText: ' ',
                  //проверяется наличие текста ошибки
                  errorText: (errorText == '') ? null : errorText,
                  prefixIcon: const Icon(Icons.chat_outlined),
                  //отображение иконки для очистки текстового поля
                  suffixIcon: IconButton(
                    onPressed: _topicNameController.clear,
                    icon: const Icon(Icons.clear),
                  ),
                  //включение внешней рамки
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                onChanged: (string) {
                  setState(() {});
                },
                //валидация данных по мере ввода
              ),
              TextField(
                //назначается контроллер
                controller: _topicDescriptionController,
                //включается текстовая клавиатура
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Описание темы',
                  //пустой helperText для предотвращения смещения виджетов при появдении ошибки
                  helperText: ' ',
                  //проверяется наличие текста ошибки
                  errorText: (errorText == '') ? null : errorText,
                  prefixIcon: const Icon(Icons.chat_outlined),
                  //отображение иконки для очистки текстового поля
                  suffixIcon: IconButton(
                    onPressed: _topicDescriptionController.clear,
                    icon: const Icon(Icons.clear),
                  ),
                  //включение внешней рамки
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                //валидация данных по мере ввода
              ),
              BlocBuilder<ImageUploadCubit, ImageUploadState>(
                builder: (context, state) {
                  final String? imageUrl = state.imageUrl?.first;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TopicAvatar(
                          topicName: _topicNameController.text,
                          topicImage: imageUrl),
                      TextButton(
                          onPressed: () => _onPickImagePressed(),
                          child: const Text('Загрузить изображение'))
                    ],
                  );
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    final String topicName = _topicNameController.text;
                    final String topicDescription =
                        _topicDescriptionController.text;
                    if (topicName.isEmpty || topicDescription.isEmpty) {
                      setState(() {
                        errorText = 'Поля не могут быть пустыми';
                      });
                    } else {
                      errorText = '';
                      _onCreateTopicPressed(
                          name: topicName, description: topicDescription);
                    }
                  },
                  child: const Text('Создать'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCreateTopicPressed(
      {required String name, required String description}) async {
    final BuildContext currentContext = context;
    final String? avatar =
        context.read<ImageUploadCubit>().state.imageUrl?.first;

    final ChatTopicDto newTopic = await context
        .read<TopicsCubit>()
        .chatTopicsRepository
        .createTopic(ChatTopicSendDto(
            name: name, description: description, avatar: avatar));
    currentContext.read<ImageUploadCubit>().clearImages();
    _pushToChat(
        context: context, chatId: newTopic.id, chatName: newTopic.name!);
  }

  Future<void> _onPickImagePressed() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      if (!mounted) return;
      context.read<ImageUploadCubit>().uploadImage(images);
    }
  }

  void _pushToChat(
      {required BuildContext context,
      required int chatId,
      required String chatName}) {
    context.read<TopicsCubit>().updateTopic(chatId, chatName);
    Navigator.pushNamed(context, AppConst.chatRoute);
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        children: const [
          Text('Создать новую тему'),
        ],
      ),
    );
  }
}

class _TopicAvatar extends StatelessWidget {
  static const double _size = 42;

  final String? topicName;
  final String? topicImage;

  const _TopicAvatar({
    required this.topicName,
    required this.topicImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String? newTopicName = topicName;
    if (newTopicName == null || newTopicName.isEmpty) {
      newTopicName = ' ';
    }
    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: Color(0xff000000 | newTopicName.hashCode),
        shape: const CircleBorder(),
        child: (topicImage == null)
            ? Center(
                child: Text(
                  newTopicName[0],
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              )
            : Image.network(
                topicImage!,
                fit: BoxFit.fitWidth,
              ),
      ),
    );
  }
}

class AvatarContent extends StatelessWidget {
  const AvatarContent({
    Key? key,
    required this.topicData,
    required this.colorScheme,
  }) : super(key: key);

  final ChatTopicDto topicData;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final avatar = topicData.avatar;
    if (avatar == null) {
      return Text(
        topicData.name != null ? topicData.name!.split('')[0] : '',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    } else {
      return Image.network(avatar);
    }
  }
}
