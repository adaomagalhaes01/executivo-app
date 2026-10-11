import '../models/car.dart';
import '../models/car_search_filter.dart';

/// Read/write access to the vehicle catalogue.
///
/// The mock implementation lives in `MockCarRepository`; once the backend is
/// connected a `SupabaseCarRepository` can be dropped in without any screen
/// changing, because the UI only ever talks to this interface.
abstract class CarRepository {
  /// Vehicles matching [criteria] and [filter], best match first.
  Future<List<Car>> search({
    required CarSearchCriteria criteria,
    CarSearchFilter filter,
  });

  /// Every published vehicle, newest first. Backs the filter sheet options.
  Future<List<Car>> fetchCatalogue();

  /// A single vehicle, or `null` when the id is unknown.
  Future<Car?> fetchById(String carId);

  /// Vehicles published by [ownerId].
  Future<List<Car>> fetchByOwner(String ownerId);

  /// Persists a listing created through the publish wizard and returns the
  /// stored record.
  Future<Car> publish(Car car);

  /// Updates an existing listing.
  Future<Car> update(Car car);

  /// Deletes a listing.
  Future<void> delete(String carId);
}