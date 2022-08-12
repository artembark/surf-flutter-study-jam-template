import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/common/app_const.dart';
import 'package:surf_practice_chat_flutter/features/auth/blocs/auth_cubit/auth_cubit.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/blocs/chat_cubit/chat_cubit.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/settings/blocs/app_settings/app_settings_cubit.dart';
import 'package:surf_practice_chat_flutter/features/topics/blocs/topics/topics_cubit.dart';

import '../models/chat_topic_dto.dart';
import 'create_topic_screen.dart';

/// Screen with different chat topics to go to.
class TopicsScreen extends StatefulWidget {
  /// Constructor for [TopicsScreen].
  const TopicsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Iterable<ChatTopicDto> _currentTopics = [];
  final _nameEditingController = TextEditingController();

  @override
  void initState() {
    context.read<ChatCubit>().getUserName();
    _onUpdatePressed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _ChatAppBar(
          controller: _nameEditingController,
          onUpdatePressed: _onUpdatePressed,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _TopicsBody(
              topics: _currentTopics,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppConst.createTopicsRoute),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final topics = await context
        .read<TopicsCubit>()
        .chatTopicsRepository
        .getTopics(
            topicsStartDate: DateTime.now().subtract(const Duration(days: 10)));
    setState(() {
      _currentTopics = topics;
    });
  }
}

class _ChatAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;
  final TextEditingController controller;

  const _ChatAppBar({
    required this.onUpdatePressed,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          context.read<AuthCubit>().logOut();
          context.read<AppSettingsCubit>().resetToken();
          Navigator.pushNamed(context, AppConst.loginRoute);
        },
      ),
      actions: [
        IconButton(
          onPressed: onUpdatePressed,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final String? userName = state.userName;
          return Column(
            children: [
              const Text('Списки чатов'),
              if (userName != null)
                FittedBox(
                  child: Text('Пользователь $userName'),
                )
            ],
          );
        },
      ),
    );
  }
}

class _TopicsBody extends StatelessWidget {
  final Iterable<ChatTopicDto> topics;

  const _TopicsBody({
    required this.topics,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: topics.length,
      itemBuilder: (_, index) {
        return _TopicItem(topicData: topics.elementAt(index));
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 2,
        );
      },
    );
  }
}

class _TopicItem extends StatelessWidget {
  final ChatTopicDto topicData;

  const _TopicItem({
    required this.topicData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pushToChat(
          context: context, chatId: topicData.id, chatName: topicData.name!),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopicAvatar(topicData: topicData),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      topicData.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      topicData.description ?? '',
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pushToChat(
      {required BuildContext context,
      required int chatId,
      required String chatName}) {
    context.read<TopicsCubit>().updateTopic(chatId, chatName);
    Navigator.pushNamed(context, AppConst.chatRoute);
  }
}

class _TopicAvatar extends StatelessWidget {
  static const double _size = 42;

  final ChatTopicDto topicData;

  const _TopicAvatar({
    required this.topicData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: Color(0xff000000 | topicData.name.hashCode),
        shape: const CircleBorder(),
        child: Center(
          child: AvatarContent(topicData: topicData, colorScheme: colorScheme),
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
