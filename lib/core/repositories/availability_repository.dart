import '../models/car.dart';

/// Reads and updates the calendar state of a vehicle.
///
/// Split from `CarRepository` so a real implementation can back it with a
/// dedicated `availability` table instead of a column on the listing.
abstract class AvailabilityRepository {
  /// Availability currently stored for [carId].
  Future<Car> fetchAvailability(String carId);

  /// Persists the availability toggle and blocked dates.
  Future<Car> saveAvailability(String carId, bool isAvailable, List<DateTime> blockedDates);

  /// Adds a blocked range, ignoring overlaps.
  Future<List<DateTime>> addBlockedRange(
    String carId, {
    required DateTime start,
    required DateTime end,
  });

  /// Removes a blocked day.
  Future<List<DateTime>> removeBlockedDate(String carId, DateTime date);

  /// Whether [start]..[end] is free for [carId].
  Future<bool> isRangeAvailable(
    String carId, {
    required DateTime start,
    required DateTime end,
  });
}