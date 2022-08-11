import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:surf_practice_chat_flutter/features/location/repository/geolocation_repository.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  GeolocationRepository geolocationRepository;

  LocationCubit({required this.geolocationRepository})
      : super(const LocationState());

  Future<void> getCurrentPosition() async {
    emit(const LocationState(locating: true));
    await geolocationRepository
        .getCurrentPosition()
        .then(
            (currentPosition) => emit(LocationState(position: currentPosition)))
        //обработка ошибки геолокации
        //можно через test поймать нужный тип и выбросить стейт в UI
        .catchError((Object error, StackTrace stackTrace) {
      if (kDebugMode) {
        print(error.toString());
        print(stackTrace);
      }
      emit(const LocationState(errorMessage: 'Неизвестная ошибка'));
    });
  }

  void resetPosition() {
    emit(const LocationState());
  }
}
