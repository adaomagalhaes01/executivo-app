import '../data/mock_rentacar_data.dart';
import '../models/car.dart';
import '../models/car_search_filter.dart';
import 'car_repository.dart';

/// Catalogue backed by the bundled seed data and an in-memory store, so
/// listings published during a session are visible everywhere (results list,
/// "Meus carros", detail screen) without a backend.
class MockCarRepository implements CarRepository {
  MockCarRepository({List<Car>? seed}) : _store = [...?seed];

  /// Simulated network latency so loading states are exercised.
  static const Duration _latency = Duration(milliseconds: 420);

  final List<Car> _store;

  List<Car> get _catalogue => _store.isEmpty ? MockRentCarData.cars : _store;

  /// Current contents of the store — lets another mock repository (for
  /// example [MockAvailabilityRepository]) start from the same catalogue.
  List<Car> get snapshot => List<Car>.unmodifiable(_catalogue);

  Future<void> _delay() => Future<void>.delayed(_latency);

  @override
  Future<List<Car>> search({
    required CarSearchCriteria criteria,
    CarSearchFilter filter = CarSearchFilter.none,
  }) async {
    await _delay();
    final results = _catalogue.where((car) {
      if (filter.matches(car, criteria)) return true;
      return false;
    }).toList();
    return _sort(results, criteria);
  }

  @override
  Future<List<Car>> fetchCatalogue() async {
    await _delay();
    return List<Car>.unmodifiable(_catalogue);
  }

  @override
  Future<Car?> fetchById(String carId) async {
    await _delay();
    for (final car in _catalogue) {
      if (car.id == carId) return car;
    }
    return null;
  }

  @override
  Future<List<Car>> fetchByOwner(String ownerId) async {
    await _delay();
    return List<Car>.unmodifiable(
      _catalogue.where((car) => car.owner.id == ownerId),
    );
  }

  @override
  Future<Car> publish(Car car) async {
    await _delay();
    _store.add(car);
    return car;
  }

  @override
  Future<Car> update(Car car) async {
    await _delay();
    final index = _store.indexWhere((existing) => existing.id == car.id);
    if (index >= 0) {
      _store[index] = car;
    } else {
      _store.add(car);
    }
    return car;
  }

  @override
  Future<void> delete(String carId) async {
    await _delay();
    _store.removeWhere((car) => car.id == carId);
  }

  /// Ratable vehicles first, then cheapest — the order a renter expects.
  List<Car> _sort(List<Car> cars, CarSearchCriteria criteria) {
    final sorted = [...cars];
    sorted.sort((a, b) {
      final byRating = b.rating.compareTo(a.rating);
      if (byRating != 0) return byRating;
      return a.pricing.pricePerDay.compareTo(b.pricing.pricePerDay);
    });
    return sorted;
  }
}