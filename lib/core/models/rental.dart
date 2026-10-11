import 'package:flutter/material.dart';

import 'car.dart';
import 'rental_location.dart';
import 'rental_pricing.dart';

/// Lifecycle of a booking request.
enum RentalStatus { pending, confirmed, rejected, cancelled, completed }

/// Portuguese labels for [RentalStatus].
extension RentalStatusX on RentalStatus {
  String get label => switch (this) {
        RentalStatus.pending => 'Pendente',
        RentalStatus.confirmed => 'Confirmada',
        RentalStatus.rejected => 'Recusada',
        RentalStatus.cancelled => 'Cancelada',
        RentalStatus.completed => 'Concluída',
      };

  /// One-line explanation shown under the badge.
  String get description => switch (this) {
        RentalStatus.pending => 'A aguardar resposta do proprietário',
        RentalStatus.confirmed => 'Veículo reservado para si',
        RentalStatus.rejected => 'O proprietário recusou o pedido',
        RentalStatus.cancelled => 'Reserva cancelada',
        RentalStatus.completed => 'Aluguer terminado',
      };

  bool get isOpen =>
      this == RentalStatus.pending || this == RentalStatus.confirmed;

  bool get isFinal => !isOpen;

  /// Icon shown next to the status badge.
  IconData get icon => switch (this) {
        RentalStatus.pending => Icons.hourglass_top_rounded,
        RentalStatus.confirmed => Icons.check_circle_rounded,
        RentalStatus.rejected => Icons.cancel_rounded,
        RentalStatus.cancelled => Icons.event_busy_rounded,
        RentalStatus.completed => Icons.task_alt_rounded,
      };
}

/// A booking of a vehicle for a period of time.
///
/// The price is snapshotted into [quote] at creation time so later changes to
/// the listing never rewrite the history of an existing booking. Renter
/// identity lives in `RentalRequest`, which is the owner-facing view.
class Rental {
  const Rental({
    required this.id,
    required this.car,
    required this.pickupDate,
    required this.returnDate,
    required this.quote,
    required this.status,
    required this.createdAt,
    this.withDelivery = false,
    this.pickupLocation,
  });

  final String id;
  final Car car;
  final DateTime pickupDate;
  final DateTime returnDate;

  /// Price breakdown captured when the request was created.
  final RentalQuote quote;

  final RentalStatus status;
  final DateTime createdAt;
  final bool withDelivery;

  /// Delivery address, kept only when [withDelivery] is true so the owner can
  /// see where the car has to be taken.
  final RentalLocation? pickupLocation;

  int get days => quote.days;

  /// Where the vehicle is actually handed over.
  RentalLocation get handoverLocation => pickupLocation ?? car.location;

  bool get delivered => withDelivery;

  /// Either side can drop a booking until the rental period starts.
  bool get canBeCancelled => status.isOpen && !isPast;
  double get total => quote.total;

  bool get isUpcoming => status.isOpen && !isPast;
  bool get isPast {
    final end = DateTime(returnDate.year, returnDate.month, returnDate.day);
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);
    return end.isBefore(now);
  }

  /// Whether the vehicle is currently handed over on this booking.
  bool get isHandoverPeriod {
    final now = DateTime.now();
    return status == RentalStatus.confirmed &&
        !now.isBefore(pickupDate) &&
        !now.isAfter(returnDate);
  }

  Rental copyWith({RentalStatus? status}) {
    return Rental(
      id: id,
      car: car,
      pickupDate: pickupDate,
      returnDate: returnDate,
      quote: quote,
      status: status ?? this.status,
      createdAt: createdAt,
      withDelivery: withDelivery,
      pickupLocation: pickupLocation,
    );
  }
}