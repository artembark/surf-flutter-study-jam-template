import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_image_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';

import '../models/chat_message_location_dto.dart';

/// Main screen of chat app, containing messages.
class ChatScreen extends StatefulWidget {
  /// Repository for chat functionality.
  final IChatRepository chatRepository;

  /// Constructor for [ChatScreen].
  const ChatScreen({
    required this.chatRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _nameEditingController = TextEditingController();

  Iterable<ChatMessageDto> _currentMessages = [];

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
            child: _ChatBody(
              messages: _currentMessages,
            ),
          ),
          _ChatTextField(onSendPressed: _onSendPressed),
        ],
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final messages = await widget.chatRepository.getMessages();
    setState(() {
      _currentMessages = messages;
    });
  }

  Future<void> _onSendPressed(String messageText) async {
    final messages = await widget.chatRepository.sendMessage(messageText);
    setState(() {
      _currentMessages = messages;
    });
  }
}

class _ChatBody extends StatelessWidget {
  final Iterable<ChatMessageDto> messages;

  const _ChatBody({
    required this.messages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (_, index) {
        return _ChatMessage(chatData: messages.elementAt(index));
      },
    );
  }
}

class _ChatTextField extends StatelessWidget {
  final ValueChanged<String> onSendPressed;

  final _textEditingController = TextEditingController();

  _ChatTextField({
    required this.onSendPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.padding.bottom + 8,
          left: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Сообщение',
                ),
              ),
            ),
            IconButton(
              onPressed: () => onSendPressed(_textEditingController.text),
              icon: const Icon(Icons.send),
              color: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onUpdatePressed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessageDto chatData;

  const _ChatMessage({
    required this.chatData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color:
          chatData.chatUserDto is ChatUserLocalDto ? colorScheme.primary : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatAvatar(userData: chatData.chatUserDto),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    chatData.chatUserDto.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(chatData.message ?? ''),
                  if (chatData is ChatMessageGeolocationDto)
                    UserGeolocationButton(
                        chatData: chatData as ChatMessageGeolocationDto),
                  if (chatData is ChatMessageImageDto)
                    UserMessageImages(
                        chatData: chatData as ChatMessageImageDto),
                  Text(
                    DateFormat("HH:mm").format(
                      chatData.createdDateTime.toLocal(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserGeolocationButton extends StatelessWidget {
  const UserGeolocationButton({
    Key? key,
    required this.chatData,
  }) : super(key: key);

  final ChatMessageGeolocationDto chatData;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.location_on_outlined),
      onPressed: () async {
        final availableMaps = await MapLauncher.installedMaps;
        await availableMaps.first.showMarker(
          coords:
              Coords(chatData.location.latitude, chatData.location.longitude),
          title: '${chatData.chatUserDto.name ?? 'Пользователь без имени'} тут',
        );
      },
      label: const Text('Открыть геолокацию на карте'),
    );
  }
}

class UserMessageImages extends StatelessWidget {
  const UserMessageImages({
    Key? key,
    required this.chatData,
  }) : super(key: key);

  final ChatMessageImageDto chatData;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20),
        itemCount: chatData.imageUrl?.length,
        itemBuilder: (BuildContext ctx, index) {
          return Image.network(chatData.imageUrl![index]);
        });

    // return Column(
    //   children: chatData.imageUrl!
    //       .map((imageUrl) => Image.network(imageUrl))
    //       .toList(),
    // );
  }
}

class _ChatAvatar extends StatelessWidget {
  static const double _size = 42;

  final ChatUserDto userData;

  const _ChatAvatar({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: Color(0xff000000 | userData.name.hashCode),
        shape: const CircleBorder(),
        child: Center(
          child: Text(
            userData.name != null
                ? '${userData.name!.split(' ').first[0]}${userData.name!.split(' ').last[0]}'
                : '',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
