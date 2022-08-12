import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/settings/blocs/app_settings/app_settings_cubit.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import '../models/chat_topic_dto.dart';
import '../repository/chart_topics_repository.dart';
import 'create_topic_screen.dart';

/// Screen with different chat topics to go to.
class TopicsScreen extends StatefulWidget {
  final IChatTopicsRepository chatTopicsRepository;

  /// Constructor for [TopicsScreen].
  const TopicsScreen({Key? key, required this.chatTopicsRepository})
      : super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Iterable<ChatTopicDto> _currentTopics = [];
  final _nameEditingController = TextEditingController();

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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _pushToCreateTopic(
          context: context,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _pushToCreateTopic({required BuildContext context}) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          final String? token =
              context.read<AppSettingsCubit>().state.tokenDto?.token;
          return CreateTopicScreen(
            chatTopicsRepository: ChatTopicsRepository(
              StudyJamClient().getAuthorizedClient(token ?? ''),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final topics = await widget.chatTopicsRepository.getTopics(
        topicsStartDate: DateTime.now().subtract(const Duration(days: 2)));
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
      actions: [
        IconButton(
          onPressed: onUpdatePressed,
          icon: const Icon(Icons.refresh),
        ),
      ],
      title: Column(
        children: [
          Text('Списки чатов'),
          FittedBox(child: Text('Пользователь UserName'))
        ],
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
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (_, index) {
        return _TopicItem(topicData: topics.elementAt(index));
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
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _pushToChat(context: context, chatId: topicData.id),
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

  void _pushToChat({required BuildContext context, required int chatId}) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          final String? token =
              context.read<AppSettingsCubit>().state.tokenDto?.token;
          return ChatScreen(
            chatRepository: ChatRepository(
              StudyJamClient().getAuthorizedClient(token ?? ''),
            ),
            chatId: chatId,
          );
        },
      ),
    );
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
