import '../models/driver_location.dart';

abstract class DriverLocationRepository {
  Stream<DriverLocation> getDriverLocation(
    String driverId, {
    required double targetLatitude,
    required double targetLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
  });
}
