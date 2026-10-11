import 'rental.dart';

/// The person who booked a vehicle, as seen by the owner.
class RentalRenter {
  const RentalRenter({
    required this.name,
    required this.rating,
    this.reviewCount = 0,
    this.phone = '',
    this.photoUrl = '',
    this.isVerified = false,
  });

  final String name;
  final double rating;
  final int reviewCount;
  final String phone;
  final String photoUrl;
  final bool isVerified;

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

/// An incoming booking request shown in "Reservas recebidas".
///
/// Wraps the [Rental] record with the renter profile and the optional message,
/// which only the owner needs — the renter-facing screens stay on [Rental].
class RentalRequest {
  const RentalRequest({
    required this.id,
    required this.rental,
    required this.renter,
    this.note = '',
  });

  final String id;
  final Rental rental;
  final RentalRenter renter;

  /// Free-text message the renter sent with the request.
  final String note;

  // ─── Delegated accessors ───────────────────────────────────────────────────

  RentalStatus get status => rental.status;
  DateTime get pickupDate => rental.pickupDate;
  DateTime get returnDate => rental.returnDate;
  int get days => rental.days;
  double get total => rental.total;

  /// Only a pending request can be answered by the owner.
  bool get canBeAnswered => status == RentalStatus.pending;

  /// Cancellable once confirmed but not yet started.
  bool get canBeCancelled =>
      status == RentalStatus.confirmed && !rental.isHandoverPeriod;

  RentalRequest copyWith({RentalStatus? status}) => RentalRequest(
        id: id,
        rental: status == null ? rental : rental.copyWith(status: status),
        renter: renter,
        note: note,
      );
}