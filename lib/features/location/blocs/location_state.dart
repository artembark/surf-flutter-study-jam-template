part of 'location_cubit.dart';

class LocationState extends Equatable {
  final Position? position;
  final bool? locating;
  final String? errorMessage;

  const LocationState({this.position, this.locating, this.errorMessage});

  @override
  List<Object?> get props => [position, locating, errorMessage];
}
