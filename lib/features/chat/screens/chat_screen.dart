import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:image_picker/image_picker.dart';

import 'package:surf_practice_chat_flutter/features/chat/models/chat_geolocation_geolocation_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_image_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/image_upload/blocs/image_upload_cubit.dart';
import 'package:surf_practice_chat_flutter/features/location/blocs/location_cubit.dart';

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
  final ScrollController _controller = ScrollController();
  Iterable<ChatMessageDto> _currentMessages = [];

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
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
            child: _ChatBody(
              controller: _controller,
              messages: _currentMessages,
            ),
          ),
          _ChatTextField(
            onMessageSendPressed: _onSendPressed,
            onGetLocationPressed: _onGetLocationPressed,
            onSendLocationPressed: _onSendLocationPressed,
            onPickImagePressed: _onPickImagePressed,
            onSendImagePressed: _onSendImagePressed,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.small(
        onPressed: _scrollDown,
        child: Icon(Icons.arrow_downward),
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

  Future<void> _onSendLocationPressed(String messageText) async {
    final latitude = context.read<LocationCubit>().state.position?.latitude;
    final longitude = context.read<LocationCubit>().state.position?.longitude;
    if (latitude != null && longitude != null) {
      final location =
          ChatGeolocationDto(latitude: latitude, longitude: longitude);
      final messages = await widget.chatRepository
          .sendGeolocationMessage(message: messageText, location: location);

      setState(() {
        _currentMessages = messages;
      });
      if (!mounted) return;
      context.read<LocationCubit>().resetPosition();
    }
  }

  void _onGetLocationPressed() async {
    context.read<LocationCubit>().getCurrentPosition();
  }

  Future<void> _onPickImagePressed() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      if (!mounted) return;
      context.read<ImageUploadCubit>().uploadImage(images);
    }
  }

  Future<void> _onSendImagePressed(String messageText) async {
    final List<String>? urlList =
        context.read<ImageUploadCubit>().state.imageUrl;
    // if (urlList != null) {
    //   print(urlList);
    //   urlList.forEach((element) {
    //     print(element);
    //   });
    //   print(messageText);
    if (urlList != null) {
      final messages = await widget.chatRepository
          .sendImageMessage(message: messageText, images: urlList);
      setState(() {
        _currentMessages = messages;
      });
      if (!mounted) return;
      context.read<ImageUploadCubit>().clearImages();
    }
  }
}

class _ChatBody extends StatelessWidget {
  final Iterable<ChatMessageDto> messages;
  final ScrollController controller;

  const _ChatBody({
    required this.messages,
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      controller: controller,
      itemCount: messages.length,
      itemBuilder: (_, index) {
        return _ChatMessage(chatData: messages.elementAt(index));
      },
    );
  }
}

class _ChatTextField extends StatelessWidget {
  final ValueChanged<String> onMessageSendPressed;
  final ValueChanged<String> onSendLocationPressed;
  final ValueChanged<String> onSendImagePressed;
  final VoidCallback onGetLocationPressed;
  final VoidCallback onPickImagePressed;

  final _textEditingController = TextEditingController();

  _ChatTextField({
    required this.onMessageSendPressed,
    required this.onSendLocationPressed,
    required this.onPickImagePressed,
    required this.onGetLocationPressed,
    required this.onSendImagePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        return Material(
          color: colorScheme.surface,
          elevation: 12,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.padding.bottom + 8,
              right: 16,
              left: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<ImageUploadCubit, ImageUploadState>(
                    builder: (context, uploadState) {
                  final List<String?>? imageUrlList = uploadState.imageUrl;
                  if (imageUrlList != null && imageUrlList.isNotEmpty) {
                    return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                        itemCount: imageUrlList.length,
                        itemBuilder: (BuildContext ctx, index) {
                          final String? imageUrl = imageUrlList[index];
                          if (imageUrl != null) {
                            return Image.network(imageUrl);
                          } else {
                            return const SizedBox.shrink();
                          }
                        });
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                if (locationState.position != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      color: Colors.amberAccent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                context.read<LocationCubit>().resetPosition(),
                            label: const Text('Отменить'),
                            icon: const Icon(Icons.location_on),
                          ),
                          const Text('Прикреплена геолокация'),
                        ],
                      ),
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () => onPickImagePressed(),
                        icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () => onGetLocationPressed(),
                        icon: const Icon(Icons.location_on_outlined)),
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _textEditingController,
                            decoration: const InputDecoration(
                              hintText: 'Сообщение',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final imageUrl =
                            context.read<ImageUploadCubit>().state.imageUrl;
                        if (locationState.position != null) {
                          onSendLocationPressed(_textEditingController.text);
                        } else if (imageUrl != null && imageUrl.isNotEmpty) {
                          onSendImagePressed(_textEditingController.text);
                        } else {
                          onMessageSendPressed(_textEditingController.text);
                        }
                      },
                      icon: const Icon(Icons.send),
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    return Bubble(
      margin: const BubbleEdges.only(top: 10, right: 40),
      alignment: Alignment.topLeft,
      nip: BubbleNip.leftTop,
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
            //_ChatAvatar(userData: chatData.chatUserDto),
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
          print(chatData.imageUrl![index]);
          return Image.network(chatData.imageUrl![index]);
        });
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
