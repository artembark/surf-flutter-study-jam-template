import 'package:surf_study_jam/surf_study_jam.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_dto.dart';

/// Data transfer object representing simple chat topic.
///
/// Is different from [ChatTopicDto], because it does not contain id.
/// This chat's topic is not yet created in API, & that's why there's
/// no id.
class ChatTopicSendDto {
  /// Topic's name.
  ///
  /// Should be less than 128 characters long.
  final String? name;

  /// Topic's description.
  ///
  /// Should be less than 1024 characters long.
  final String? description;

  /// Constructor for [ChatTopicDto].
  const ChatTopicSendDto({
    this.name,
    this.description,
  });

  /// Transforms from [ChatTopicSendDto] to API model [SjChatSendsDto].
  SjChatSendsDto toSjChatSendsDto() => SjChatSendsDto(
        name: name,
        description: description,
      );

  @override
  String toString() => 'ChatTopicSendDto(name: $name, description: $description)';
}
