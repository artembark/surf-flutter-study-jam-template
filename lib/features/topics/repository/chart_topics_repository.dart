import 'package:surf_study_jam/surf_study_jam.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';

/// Basic interface for chat topics features.
///
/// The only tool needed to implement the chat topics.
abstract class IChatTopicsRepository {
  /// Gets all chat topics.
  ///
  /// Use [topicsStartDate] to specify from which moment, you
  /// would like to get topics. For example, if topic was made
  /// yesterday & you want to retrieve it, you should pass
  /// [DateTime.now].subtract(Duration(days:1))
  Future<Iterable<ChatTopicDto>> getTopics({
    required DateTime topicsStartDate,
  });

  /// Creates new chat topic.
  ///
  /// Retrieves [ChatTopicDto] with its unique id, once its
  /// created.
  Future<ChatTopicDto> createTopic(ChatTopicSendDto chatTopicSendDto);
}

/// Simple implementation of [IChatTopicsRepository], using [StudyJamClient].
class ChatTopicsRepository implements IChatTopicsRepository {
  final StudyJamClient _studyJamClient;

  /// Constructor for [ChatTopicsRepository].
  ChatTopicsRepository(this._studyJamClient);

  @override
  Future<Iterable<ChatTopicDto>> getTopics({
    required DateTime topicsStartDate,
  }) async {
    final updates = await _studyJamClient.getUpdates(chats: topicsStartDate);
    final topicsIds = updates.chats;
    if (topicsIds == null) {
      return [];
    }
    final topics = await _studyJamClient.getChatsByIds(topicsIds);

    return topics.map((sjChatDto) => ChatTopicDto.fromSJClient(sjChatDto: sjChatDto));
  }

  @override
  Future<ChatTopicDto> createTopic(ChatTopicSendDto chatTopicSendDto) async {
    final sjChatDto = await _studyJamClient.createChat(chatTopicSendDto.toSjChatSendsDto());

    return ChatTopicDto.fromSJClient(sjChatDto: sjChatDto);
  }
}
