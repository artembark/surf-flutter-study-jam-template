part of 'topics_cubit.dart';

class TopicsState extends Equatable {
  final int? currentId;
  final String? chatName;

  const TopicsState({this.currentId, this.chatName});

  @override
  List<Object?> get props => [currentId, chatName];
}
