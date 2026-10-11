import 'dart:async';
import 'dart:math';

import '../models/driver_location.dart';
import 'driver_location_repository.dart';

class MockDriverLocationRepository implements DriverLocationRepository {
  @override
  Stream<DriverLocation> getDriverLocation(
    String driverId, {
    required double targetLatitude,
    required double targetLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
  }) async* {
    // Demo driver starts a few streets away from the passenger.
    double currentLat = targetLatitude + 0.004;
    double currentLng = targetLongitude - 0.005;
    // Accelerated local simulation keeps the demo moving without long waits.
    const speed = 0.0004;
    var hasPickedUp = false;

    while (true) {
      await Future.delayed(const Duration(milliseconds: 1000));

      final nextLat = hasPickedUp && dropoffLatitude != null
          ? dropoffLatitude
          : targetLatitude;
      final nextLng = hasPickedUp && dropoffLongitude != null
          ? dropoffLongitude
          : targetLongitude;
      double dLat = nextLat - currentLat;
      double dLng = nextLng - currentLng;
      double distance = sqrt(dLat * dLat + dLng * dLng);

      double heading = atan2(dLng, dLat) * (180 / pi);
      if (heading < 0) heading += 360;

      if (distance < speed) {
        currentLat = nextLat;
        currentLng = nextLng;
      } else {
        currentLat += (dLat / distance) * speed;
        currentLng += (dLng / distance) * speed;
      }

      yield DriverLocation(
        driverId: driverId,
        latitude: currentLat,
        longitude: currentLng,
        heading: heading,
        speed: 40.0, // mock speed 40km/h
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      if (currentLat == nextLat && currentLng == nextLng) {
        if (!hasPickedUp &&
            dropoffLatitude != null &&
            dropoffLongitude != null) {
          hasPickedUp = true;
        } else {
          break;
        }
      }
    }
  }
}
