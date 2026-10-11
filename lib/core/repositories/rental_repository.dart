import '../models/rental.dart';
import '../models/rental_request.dart';

/// Read/write access to bookings, for both sides of the marketplace.
abstract class RentalRepository {
  /// Bookings made by [renterId] — backs "Minhas reservas".
  Future<List<Rental>> fetchRentalsOfRenter(String renterId);

  /// Requests received for the vehicles of [ownerId] — backs
  /// "Reservas recebidas".
  Future<List<RentalRequest>> fetchRequestsOfOwner(String ownerId);

  /// A single booking.
  Future<Rental?> fetchById(String rentalId);

  /// Creates a pending request.
  Future<Rental> createRequest(Rental rental);

  /// Moves a request to [status] (confirmed, rejected, cancelled, completed).
  Future<Rental> updateStatus(String rentalId, RentalStatus status);
}