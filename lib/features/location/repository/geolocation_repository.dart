import 'package:geolocator/geolocator.dart';

import '../datasource/geolocator_data_source.dart';

/// Репозиторий для получения геолокации
abstract class GeolocationRepository {
  Future<Position> getCurrentPosition();
}

class GeolocationRepositoryImpl implements GeolocationRepository {
  LocationDataSource locationDataSource;

  GeolocationRepositoryImpl({required this.locationDataSource});

  @override
  Future<Position> getCurrentPosition() async {
    final location = await locationDataSource.getCurrentPosition();
    return location;
  }
}
