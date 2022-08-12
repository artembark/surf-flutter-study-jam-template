part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final String? userName;

  const ChatState({this.userName});

  @override
  List<Object?> get props => [userName];
}
