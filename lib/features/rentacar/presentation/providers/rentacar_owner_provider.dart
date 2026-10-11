import 'package:flutter/foundation.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/models/car_listing_draft.dart';
import '../../../../core/models/rental_owner.dart';
import '../../../../core/repositories/availability_repository.dart';
import '../../../../core/repositories/car_repository.dart';

/// Owner's view of the module: their listings and the publish wizard.
///
/// Repository instances are injected from `main.dart` so the renter flow and
/// the owner flow share the same store — a car published here shows up in the
/// search results immediately.
class RentCarOwnerProvider extends ChangeNotifier {
  RentCarOwnerProvider({
    required this.carRepository,
    required this.availabilityRepository,
  });

  final CarRepository carRepository;
  final AvailabilityRepository availabilityRepository;

  /// Identity of the signed-in user — mocked until auth is connected.
  static const String currentOwnerId = 'owner_current';

  static const RentalOwner currentOwner = RentalOwner(
    id: currentOwnerId,
    name: 'Adão Magalhães',
    rating: 5,
    totalRentals: 12,
    isVerified: true,
  );

  bool _isLoading = false;
  bool _isPublishing = false;
  String _errorMessage = '';
  List<Car> _myCars = const [];
  CarListingDraft _draft = const CarListingDraft();

  bool get isLoading => _isLoading;
  bool get isPublishing => _isPublishing;
  String get errorMessage => _errorMessage;
  List<Car> get myCars => _myCars;
  CarListingDraft get draft => _draft;

  int get activeCarsCount =>
      _myCars.where((car) => car.status == CarStatus.active).length;

  int get pausedCarsCount =>
      _myCars.where((car) => car.status == CarStatus.paused).length;

  /// Loads the vehicles published by the current user.
  Future<void> loadMyCars() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _myCars = await carRepository.fetchByOwner(currentOwnerId);
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os seus veículos.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Car? carById(String carId) {
    for (final car in _myCars) {
      if (car.id == carId) return car;
    }
    return null;
  }

  // ─── Listing management ────────────────────────────────────────────────────

  /// Pauses an active listing, or resumes a paused one.
  Future<void> toggleListingStatus(String carId) async {
    final car = carById(carId);
    if (car == null) return;
    await _persist(
      car.copyWith(
        status: car.status == CarStatus.active
            ? CarStatus.paused
            : CarStatus.active,
      ),
    );
  }

  /// Marks a listing as currently rented, or releases it back to active.
  Future<void> markRented(String carId, {required bool rented}) async {
    final car = carById(carId);
    if (car == null) return;
    await _persist(
      car.copyWith(
        status: rented ? CarStatus.rented : CarStatus.active,
      ),
    );
  }

  Future<void> _persist(Car car) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await carRepository.update(car);
      _myCars = await carRepository.fetchByOwner(currentOwnerId);
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar o veículo.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteListing(String carId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await carRepository.delete(carId);
      _myCars = await carRepository.fetchByOwner(currentOwnerId);
    } catch (_) {
      _errorMessage = 'Não foi possível remover o veículo.';
    }
    _isLoading = false;
    notifyListeners();
  }

  // ─── Availability ──────────────────────────────────────────────────────────

  /// Blocks a range of dates on one of the owner's vehicles.
  Future<bool> blockDates(
    String carId, {
    required DateTime start,
    required DateTime end,
  }) async {
    return _mutateAvailability(() async {
      await availabilityRepository.addBlockedRange(
        carId,
        start: start,
        end: end,
      );
    }, carId);
  }

  /// Unblocks a single day.
  Future<bool> unblockDate(String carId, DateTime date) async {
    return _mutateAvailability(
      () => availabilityRepository.removeBlockedDate(carId, date),
      carId,
    );
  }

  /// Switches a listing between available and unavailable.
  Future<bool> setAvailability(String carId, bool available) async {
    final car = carById(carId);
    if (car == null) return false;
    return _mutateAvailability(
      () => availabilityRepository.saveAvailability(
        carId,
        available,
        car.availability.blockedPeriods
            .expand((p) => [p.start, p.end])
            .toList(growable: false),
      ),
      carId,
    );
  }

  Future<bool> _mutateAvailability(
    Future<void> Function() action,
    String carId,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    var succeeded = true;
    try {
      await action();
      final updated = await availabilityRepository.fetchAvailability(carId);
      _myCars = [
        for (final car in _myCars)
          car.id == carId ? updated : car,
      ];
    } catch (_) {
      succeeded = false;
      _errorMessage = 'Não foi possível atualizar a disponibilidade.';
    }
    _isLoading = false;
    notifyListeners();
    return succeeded;
  }

  // ─── Publish wizard ────────────────────────────────────────────────────────

  void updateDraft(CarListingDraft draft) {
    _draft = draft;
    notifyListeners();
  }

  /// Jumps to [step], but only forwards when the current step is complete.
  void goToStep(PublishStep step) {
    final current = _draft.currentStep;
    if (step.index > current.index && !_draft.isStepValid(current)) return;
    updateDraft(_draft.copyWith(currentStep: step));
  }

  void goNext() {
    final steps = PublishStep.values;
    final current = steps.indexOf(_draft.currentStep);
    if (current < 0 || current >= steps.length - 1) return;
    updateDraft(_draft.copyWith(currentStep: steps[current + 1]));
  }

  void goBack() {
    final steps = PublishStep.values;
    final current = steps.indexOf(_draft.currentStep);
    if (current <= 0) return;
    updateDraft(_draft.copyWith(currentStep: steps[current - 1]));
  }

  void resetDraft() {
    _draft = const CarListingDraft();
    notifyListeners();
  }

  /// Converts wizard state into a persistable [Car], or `null` when the draft
  /// is not publishable yet.
  Car? carFromDraft(CarListingDraft draft) {
    if (!draft.isVehicleValid ||
        !draft.hasCoverPhoto ||
        !draft.isPricingValid ||
        !draft.isLocationValid) {
      return null;
    }

    return Car(
      id: 'car_${DateTime.now().microsecondsSinceEpoch}',
      brand: draft.brand.trim(),
      model: draft.model.trim(),
      year: draft.year!,
      plate: draft.plate.trim().toUpperCase(),
      color: draft.color.trim(),
      mileageKm: draft.mileageKm!,
      transmission: draft.transmission!,
      fuel: draft.fuel!,
      seats: draft.seats!,
      pricing: draft.pricing,
      location: draft.location!,
      images: draft.images,
      owner: currentOwner,
      description: draft.description.trim(),
      features: draft.features,
      rules: draft.rules,
      availability: draft.availability,
      rating: 0,
      reviewsCount: 0,
      status: CarStatus.active,
      createdAt: DateTime.now(),
    );
  }

  /// Persists the draft and returns the stored listing.
  Future<Car?> publishDraft() async {
    final car = carFromDraft(_draft);
    if (car == null) return null;

    _isPublishing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final saved = await carRepository.publish(car);
      _draft = const CarListingDraft();
      _myCars = await carRepository.fetchByOwner(currentOwnerId);
      return saved;
    } catch (_) {
      _errorMessage = 'Não foi possível publicar o veículo.';
      return null;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }
}