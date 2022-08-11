part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final TokenDto? tokenDto;
  final bool loading;
  final String? errorMessage;

  const AuthState({this.tokenDto, this.loading = false, this.errorMessage});

  @override
  List<Object?> get props => [tokenDto, loading, errorMessage];
}
