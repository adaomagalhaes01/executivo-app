import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Kind of pickup point — drives the icon in the location picker and the
/// copy shown on the listing card.
enum LocationKind { neighbourhood, airport, mall, hotel, office, other }

/// Pickup point of a vehicle.
///
/// Mirrors the coordinates the backend will receive so the location picker
/// and the map view share a single source of truth.
class RentalLocation {
  const RentalLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.neighbourhood = '',
    this.city = '',
    this.kind = LocationKind.neighbourhood,
  });

  final double latitude;
  final double longitude;

  /// Street address shown to the renter.
  final String address;

  /// Short area name used in listing cards ("Talatona", "Miramar", ...).
  final String neighbourhood;

  /// City the point belongs to — used to group the picker results.
  final String city;

  final LocationKind kind;

  LatLng get coordinates => LatLng(latitude, longitude);

  String get label => neighbourhood.isNotEmpty ? neighbourhood : address;

  /// Two points are the same place when they share coordinates, which keeps
  /// the "selected" check working without a persisted id.
  bool sameAs(RentalLocation other) =>
      other.latitude == latitude && other.longitude == longitude;

  RentalLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? neighbourhood,
    String? city,
    LocationKind? kind,
  }) {
    return RentalLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      neighbourhood: neighbourhood ?? this.neighbourhood,
      city: city ?? this.city,
      kind: kind ?? this.kind,
    );
  }
}