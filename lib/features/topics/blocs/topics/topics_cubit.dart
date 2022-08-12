import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chart_topics_repository.dart';

part 'topics_state.dart';

class TopicsCubit extends Cubit<TopicsState> {
  IChatTopicsRepository chatTopicsRepository;

  TopicsCubit({required this.chatTopicsRepository})
      : super(const TopicsState());

  void updateTopic(int newTopicId, String chatName) {
    emit(TopicsState(currentId: newTopicId, chatName: chatName));
  }
}
