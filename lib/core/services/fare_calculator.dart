import 'dart:math';

import '../models/vehicle_category.dart';
import '../models/zone.dart';

class FareCalculator {
  const FareCalculator();

  double distanceKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    const radians = pi / 180;
    const earthRadiusKm = 6371.0;
    final dLat = (toLatitude - fromLatitude) * radians;
    final dLng = (toLongitude - fromLongitude) * radians;
    final a =
        pow(sin(dLat / 2), 2) +
        cos(fromLatitude * radians) *
            cos(toLatitude * radians) *
            pow(sin(dLng / 2), 2);
    return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double estimate({
    required double distanceKm,
    required Zone zone,
    required VehicleCategory vehicle,
  }) {
    const baseFare = 800.0;
    const pricePerKm = 350.0;
    return (baseFare + distanceKm * pricePerKm + zone.price) *
        vehicle.priceMultiplier;
  }
}
