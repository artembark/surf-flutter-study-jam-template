import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final IChatRepository chatRepository;

  ChatCubit({required this.chatRepository}) : super(const ChatState());

  void getUserName() async {
    await chatRepository
        .getLocalUser()
        .then((userDto) => emit(ChatState(userName: userDto.name)));
  }
}
