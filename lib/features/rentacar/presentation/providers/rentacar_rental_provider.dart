import 'package:flutter/foundation.dart';

import '../../../../core/models/rental.dart';
import '../../../../core/models/rental_request.dart';
import '../../../../core/repositories/rental_repository.dart';
import 'rentacar_owner_provider.dart';

/// Drives the booking lifecycle from both sides of the marketplace.
///
/// "Minhas reservas" and "Reservas recebidas" read from the same store, so
/// confirming a request in the owner view is immediately reflected in the
/// renter's list.
class RentCarRentalProvider extends ChangeNotifier {
  RentCarRentalProvider({required this.rentalRepository});

  final RentalRepository rentalRepository;

  /// Identity of the signed-in renter — mocked until auth is connected.
  static const String currentRenterId = 'renter_current';

  bool _isLoading = false;
  bool _isSubmitting = false;
  String _errorMessage = '';
  List<Rental> _myRentals = const [];
  List<RentalRequest> _receivedRequests = const [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;

  /// Bookings made by the current user.
  List<Rental> get myRentals => _myRentals;

  /// Requests received for the current user's vehicles.
  List<RentalRequest> get receivedRequests => _receivedRequests;

  List<RentalRequest> get pendingRequests => _receivedRequests
      .where((request) => request.status == RentalStatus.pending)
      .toList(growable: false);

  List<RentalRequest> get actionableRequests => _receivedRequests
      .where((request) => request.canBeAnswered)
      .toList(growable: false);

  /// Count of pending requests per vehicle, used by the "Meus carros" badges.
  Map<String, int> get pendingCountByCar {
    final counts = <String, int>{};
    for (final request in pendingRequests) {
      final id = request.rental.car.id;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  List<Rental> get upcomingRentals =>
      _myRentals.where((rental) => rental.isUpcoming).toList(growable: false);

  List<Rental> get pastRentals =>
      _myRentals.where((rental) => rental.isPast).toList(growable: false);

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        rentalRepository.fetchRentalsOfRenter(currentRenterId),
        rentalRepository.fetchRequestsOfOwner(
          RentCarOwnerProvider.currentOwnerId,
        ),
      ]);
      _myRentals = results[0] as List<Rental>;
      _receivedRequests = results[1] as List<RentalRequest>;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as reservas.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyRentals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _myRentals =
          await rentalRepository.fetchRentalsOfRenter(currentRenterId);
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as suas reservas.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadReceivedRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      _receivedRequests = await rentalRepository.fetchRequestsOfOwner(
        RentCarOwnerProvider.currentOwnerId,
      );
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os pedidos recebidos.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Creates a pending booking and returns the stored record.
  Future<Rental?> requestBooking(Rental rental) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final created = await rentalRepository.createRequest(rental);
      _myRentals = [created, ..._myRentals];
      return created;
    } catch (_) {
      _errorMessage = 'Não foi possível solicitar a reserva.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Owner action: accept a pending request.
  Future<bool> confirmRequest(String rentalId) =>
      _setStatus(rentalId, RentalStatus.confirmed);

  /// Owner action: decline a pending request.
  Future<bool> rejectRequest(String rentalId) =>
      _setStatus(rentalId, RentalStatus.rejected);

  /// Either side cancels a booking that has not started yet.
  Future<bool> cancelRental(String rentalId) =>
      _setStatus(rentalId, RentalStatus.cancelled);

  Future<bool> _setStatus(String rentalId, RentalStatus status) async {
    _isSubmitting = true;
    notifyListeners();

    var succeeded = true;
    try {
      await rentalRepository.updateStatus(rentalId, status);
      _myRentals = [
        for (final rental in _myRentals)
          rental.id == rentalId ? rental.copyWith(status: status) : rental,
      ];
      _receivedRequests = [
        for (final request in _receivedRequests)
          request.rental.id == rentalId
              ? request.copyWith(status: status)
              : request,
      ];
    } catch (_) {
      succeeded = false;
      _errorMessage = 'Não foi possível atualizar a reserva.';
    }
    _isSubmitting = false;
    notifyListeners();
    return succeeded;
  }

  /// Number of pending requests for a given vehicle.
  int pendingCountFor(String carId) => pendingCountByCar[carId] ?? 0;
}