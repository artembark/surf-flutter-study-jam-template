import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Data transfer object representing chat message with image.
class ChatMessageImageDto extends ChatMessageDto {
  /// Chat message image urls list.
  final List<String>? imageUrl;

  /// Constructor for [ChatMessageImageDto].
  ChatMessageImageDto({
    required ChatUserDto chatUserDto,
    required this.imageUrl,
    required String message,
    required DateTime createdDate,
  }) : super(
          chatUserDto: chatUserDto,
          message: message,
          createdDateTime: createdDate,
        );

  /// Named constructor for converting DTO from [StudyJamClient].
  ChatMessageImageDto.fromSJClient({
    required SjMessageDto sjMessageDto,
    required SjUserDto sjUserDto,
  })  : imageUrl = sjMessageDto.images,
        super(
          createdDateTime: sjMessageDto.created,
          message: sjMessageDto.text,
          chatUserDto: ChatUserDto.fromSJClient(sjUserDto),
        );

  @override
  String toString() =>
      'ChatMessageImageDto(location: $imageUrl) extends ${super.toString()}';
}
