import 'package:google_maps_flutter/google_maps_flutter.dart';

class Zone {
  final String id;
  final String name;
  final String description;
  final double price;
  final LatLng coordinates;

  const Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.coordinates,
  });
}
