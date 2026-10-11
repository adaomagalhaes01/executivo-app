import 'package:flutter/foundation.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/models/car_search_filter.dart';
import '../../../../core/models/rental_location.dart';
import '../../../../core/repositories/car_repository.dart';
import '../../../../core/repositories/mock_car_repository.dart';

/// Loading state of a search request.
enum CarSearchStatus { idle, loading, ready, error }

/// Drives the renter flow: the search form, the result list and the filters.
///
/// Holds no screen state — the repository does the work and this provider only
/// exposes the outcome, so swapping in a networked `CarRepository` needs no
/// change here either.
class CarSearchProvider extends ChangeNotifier {
  CarSearchProvider({CarRepository? repository})
      : _repository = repository ?? MockCarRepository();

  final CarRepository _repository;

  CarSearchStatus _status = CarSearchStatus.idle;
  String _errorMessage = '';
  List<Car> _results = const [];
  List<Car> _catalogue = const [];
  CarSearchCriteria _criteria = const CarSearchCriteria();
  CarSearchFilter _filter = CarSearchFilter.none;
  int _requestId = 0;

  CarSearchStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<Car> get results => _results;
  List<Car> get catalogue => _catalogue;
  CarSearchCriteria get criteria => _criteria;
  CarSearchFilter get filter => _filter;
  bool get hasSearched => _status != CarSearchStatus.idle;
  bool get isLoading => _status == CarSearchStatus.loading;

  /// Looks a car up in the loaded data, falling back to the catalogue.
  ///
  /// Detail and booking screens receive only the id so they survive a rebuild;
  /// once a repository is wired this becomes a single `fetchById` call.
  Car? carById(String carId) {
    for (final car in [..._results, ..._catalogue]) {
      if (car.id == carId) return car;
    }
    return null;
  }

  /// Distinct brands present in the catalogue, for the filter sheet.
  List<String> get availableBrands => Car.brandsOf(_catalogue);

  /// Distinct models for a brand, for the filter sheet.
  List<String> availableModels(String brand) =>
      Car.modelsOf(_catalogue, brand);

  /// Distinct areas present in the catalogue.
  List<String> get availableAreas => _catalogue
      .map((car) => car.location.label)
      .toSet()
      .toList()
    ..sort();

  /// Union of every feature advertised by the catalogue.
  List<String> get availableFeatures => _catalogue
      .expand((car) => car.features)
      .toSet()
      .toList()
    ..sort();

  /// Price bounds of the catalogue, used to seed the filter slider.
  double get minPrice => _catalogue.isEmpty
      ? 0
      : _catalogue
          .map((car) => car.pricing.pricePerDay)
          .reduce((a, b) => a < b ? a : b);

  double get maxPrice => _catalogue.isEmpty
      ? 0
      : _catalogue
          .map((car) => car.pricing.pricePerDay)
          .reduce((a, b) => a > b ? a : b);

  List<int> get availableSeatCounts =>
      (_catalogue.map((car) => car.seats).toSet().toList()..sort());

  List<TransmissionType> get availableTransmissions => _catalogue
      .map((car) => car.transmission)
      .toSet()
      .toList();

  List<FuelType> get availableFuels =>
      _catalogue.map((car) => car.fuel).toSet().toList();

  /// Loads the catalogue used to populate filter options.
  Future<void> loadCatalogue() async {
    try {
      _catalogue = await _repository.fetchCatalogue();
      notifyListeners();
    } catch (_) {
      // Filters degrade to the raw list; a failure here is not fatal.
    }
  }

  void updateCriteria(CarSearchCriteria criteria) {
    _criteria = criteria;
    notifyListeners();
  }

  void setLocation(RentalLocation? location) {
    _criteria = _criteria.copyWith(location: location);
    notifyListeners();
  }

  void setDates({DateTime? pickup, DateTime? returnDate, bool clear = false}) {
    _criteria = _criteria.copyWith(
      pickupDate: pickup,
      returnDate: returnDate,
      clearDates: clear,
    );
    notifyListeners();
  }

  void setDelivery(bool value) {
    _criteria = _criteria.copyWith(withDelivery: value);
    notifyListeners();
  }

  void updateFilter(CarSearchFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _filter = CarSearchFilter.none;
    notifyListeners();
  }

  void reset() {
    _requestId++;
    _status = CarSearchStatus.idle;
    _results = const [];
    _errorMessage = '';
    _criteria = const CarSearchCriteria();
    _filter = CarSearchFilter.none;
    notifyListeners();
  }

  /// Runs the search for the current criteria and filter.
  Future<void> search() async {
    final requestId = ++_requestId;
    _status = CarSearchStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final cars =
          await _repository.search(criteria: _criteria, filter: _filter);
      if (requestId != _requestId) return;
      _results = cars;
      _status = CarSearchStatus.ready;
    } catch (_) {
      if (requestId != _requestId) return;
      _status = CarSearchStatus.error;
      _errorMessage =
          'Não foi possível carregar os veículos. Tente novamente.';
    }
    notifyListeners();
  }

  /// Applies a new filter to the results already on screen.
  Future<void> applyFilter(CarSearchFilter filter) async {
    _filter = filter;
    if (_status == CarSearchStatus.idle) {
      notifyListeners();
      return;
    }
    await search();
  }

  /// Toggles the favourite flag of a car inside the current result set.
  void toggleFavorite(String carId) {
    _results = [
      for (final car in _results)
        car.id == carId ? car.copyWith(isFavorite: !car.isFavorite) : car,
    ];
    notifyListeners();
  }
}