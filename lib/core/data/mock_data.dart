import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/vehicle_category.dart';
import '../models/zone.dart';

abstract final class MockData {
  static const zones = <Zone>[
    Zone(
      id: 'central',
      name: 'Zona Central',
      description: 'Centro de Luanda',
      price: 0,
      coordinates: LatLng(-8.814, 13.230),
    ),
    Zone(
      id: 'south',
      name: 'Zona Sul',
      description: 'Talatona e arredores',
      price: 500,
      coordinates: LatLng(-8.920, 13.190),
    ),
    Zone(
      id: 'north',
      name: 'Zona Norte',
      description: 'Sambizanga e arredores',
      price: 350,
      coordinates: LatLng(-8.790, 13.250),
    ),
    Zone(
      id: 'east',
      name: 'Zona Leste',
      description: 'Viana e arredores',
      price: 700,
      coordinates: LatLng(-8.900, 13.370),
    ),
    Zone(
      id: 'west',
      name: 'Zona Oeste',
      description: 'Miramar e arredores',
      price: 250,
      coordinates: LatLng(-8.810, 13.210),
    ),
  ];

  static const vehicles = <VehicleCategory>[
    VehicleCategory(
      id: 'baza',
      name: 'Heetch Baza',
      description: 'Affordable, w/o AC.',
      capacity: 4,
      etaMinutes: 4,
      priceMultiplier: 0.9,
      vehicleModel: 'Toyota Yaris',
    ),
    VehicleCategory(
      id: 'cool',
      name: 'Heetch Cool',
      description: 'Comfort w/ AC.',
      capacity: 4,
      etaMinutes: 6,
      priceMultiplier: 1.2,
      vehicleModel: 'Toyota Corolla',
    ),
    VehicleCategory(
      id: 'boss',
      name: 'Heetch Boss',
      description: 'SUV or pickup with AC',
      capacity: 4,
      etaMinutes: 8,
      priceMultiplier: 1.45,
      vehicleModel: 'Hyundai Tucson',
    ),
  ];
}
