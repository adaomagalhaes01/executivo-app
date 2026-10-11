import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/data/mock_data.dart';
import '../../../../core/models/driver.dart';
import '../../../../core/models/driver_location.dart';
import '../../../../core/models/trip.dart';
import '../../../../core/models/trip_state.dart';
import '../../../../core/models/vehicle_category.dart';
import '../../../../core/models/zone.dart';
import '../../../../core/repositories/driver_location_repository.dart';
import '../../../../core/repositories/mock_driver_location_repository.dart';
import '../../../../core/services/fare_calculator.dart';
import '../../../../core/services/location_service.dart';

class PlaceResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class TripStateProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final DriverLocationRepository _driverRepo = MockDriverLocationRepository();
  final FareCalculator _fareCalculator = const FareCalculator();
  final List<Trip> _tripHistory = [
    Trip(
      id: 'mock-1',
      origin: 'Miramar',
      destination: 'Aeroporto',
      date: DateTime(2026, 9, 28, 14, 15),
      value: 3800,
      paymentMethod: 'Dinheiro',
      status: 'Concluída',
    ),
    Trip(
      id: 'mock-2',
      origin: 'Luanda Shopping',
      destination: 'Talatona',
      date: DateTime(2026, 9, 27, 10, 30),
      value: 2500,
      paymentMethod: 'Cartão',
      status: 'Concluída',
      category: 'Conforto',
    ),
  ];

  TripState _tripState = TripState.idle;
  LatLng? _passengerLocation;
  PlaceResult? _destination;
  Driver? _assignedDriver;
  DriverLocation? _driverLocation;
  VehicleCategory? _selectedVehicle;
  Zone? _selectedZone;
  String _errorMessage = '';
  bool _isPickingDestination = false;
  StreamSubscription<DriverLocation>? _driverSub;
  StreamSubscription<Position>? _locationSub;
  int _requestGeneration = 0;

  TripState get tripState => _tripState;
  LatLng? get passengerLocation => _passengerLocation;
  PlaceResult? get destination => _destination;
  Driver? get assignedDriver => _assignedDriver;
  DriverLocation? get driverLocation => _driverLocation;
  String get errorMessage => _errorMessage;
  bool get isPickingDestination => _isPickingDestination;
  VehicleCategory? get selectedVehicle => _selectedVehicle;
  Zone? get selectedZone => _selectedZone;
  List<Trip> get tripHistory => List.unmodifiable(_tripHistory);

  double? get tripDistanceKm {
    final pickup = _passengerLocation;
    final dropoff = _destination;
    if (pickup == null || dropoff == null) return null;
    return _fareCalculator.distanceKm(
      fromLatitude: pickup.latitude,
      fromLongitude: pickup.longitude,
      toLatitude: dropoff.latitude,
      toLongitude: dropoff.longitude,
    );
  }

  int? get tripEtaMinutes {
    final distance = tripDistanceKm;
    return distance == null ? null : max(1, (distance / 25 * 60).ceil());
  }

  Zone? get suggestedZone =>
      _selectedZone ??
      (_destination == null
          ? null
          : zoneFor(LatLng(_destination!.latitude, _destination!.longitude)));

  double? get estimatedFare {
    final distance = tripDistanceKm;
    final zone = suggestedZone;
    final vehicle = _selectedVehicle ?? MockData.vehicles.first;
    if (distance == null || zone == null) return null;
    return _fareCalculator.estimate(
      distanceKm: distance,
      zone: zone,
      vehicle: vehicle,
    );
  }

  double? fareFor(VehicleCategory vehicle) {
    final distance = tripDistanceKm;
    final zone = suggestedZone;
    if (distance == null || zone == null) return null;
    return _fareCalculator.estimate(
      distanceKm: distance,
      zone: zone,
      vehicle: vehicle,
    );
  }

  double? get driverDistanceKm {
    final target = _trackingTarget;
    final driver = _driverLocation;
    if (driver == null || target == null) return null;
    return _fareCalculator.distanceKm(
      fromLatitude: driver.latitude,
      fromLongitude: driver.longitude,
      toLatitude: target.latitude,
      toLongitude: target.longitude,
    );
  }

  int? get driverEtaMinutes {
    final distance = driverDistanceKm;
    return distance == null ? null : max(1, (distance / 0.35).ceil());
  }

  Zone zoneFor(LatLng location) {
    return MockData.zones.reduce((nearest, zone) {
      final nearestDistance = _fareCalculator.distanceKm(
        fromLatitude: location.latitude,
        fromLongitude: location.longitude,
        toLatitude: nearest.coordinates.latitude,
        toLongitude: nearest.coordinates.longitude,
      );
      final candidateDistance = _fareCalculator.distanceKm(
        fromLatitude: location.latitude,
        fromLongitude: location.longitude,
        toLatitude: zone.coordinates.latitude,
        toLongitude: zone.coordinates.longitude,
      );
      return candidateDistance < nearestDistance ? zone : nearest;
    });
  }

  Future<void> initLocation() async {
    _errorMessage = '';
    notifyListeners();
    try {
      if (!await _locationService.isServiceEnabled) {
        _errorMessage =
            'O GPS está desligado. Active a localização do dispositivo.';
        notifyListeners();
        return;
      }
      final permission = await _locationService.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        _errorMessage =
            'Permissão de localização bloqueada. Active-a nas definições.';
        notifyListeners();
        return;
      }
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Permissão de localização negada.';
        notifyListeners();
        return;
      }
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        _errorMessage = 'Localização indisponível. Verifique o sinal GPS e tente novamente.';
        notifyListeners();
        return;
      }
      _setPassengerPosition(position);
      await _locationSub?.cancel();
      _locationSub = _locationService.watchPosition().listen(
        _setPassengerPosition,
        onError: (_) {
          _errorMessage = 'Ocorreu um erro ao actualizar a localização.';
          notifyListeners();
        },
      );
    } catch (_) {
      _errorMessage = 'Não foi possível obter a localização. Tente novamente.';
      notifyListeners();
    }
  }

  void _setPassengerPosition(Position position) {
    _passengerLocation = LatLng(position.latitude, position.longitude);
    if (_destination == null) _selectedZone = null;
    _errorMessage = '';
    notifyListeners();
  }

  void setDestination(PlaceResult place) {
    _destination = place;
    _selectedZone = zoneFor(LatLng(place.latitude, place.longitude));
    _selectedVehicle = null;
    _isPickingDestination = false;
    _tripState = TripState.destinationSelected;
    notifyListeners();
  }

  void selectDestinationOnMap(LatLng location) {
    setDestination(
      PlaceResult(
        name: 'Local seleccionado no mapa',
        address:
            '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
  }

  void startDestinationMapPick() {
    _isPickingDestination = true;
    notifyListeners();
  }

  void selectZone(Zone zone) {
    _selectedZone = zone;
    notifyListeners();
  }

  void selectVehicle(VehicleCategory vehicle) {
    _selectedVehicle = vehicle;
    _tripState = TripState.vehicleSelected;
    notifyListeners();
  }

  void backToDestination() {
    _selectedVehicle = null;
    _tripState = _destination == null
        ? TripState.idle
        : TripState.destinationSelected;
    notifyListeners();
  }

  Future<void> requestDriver() async {
    if (_destination == null || _passengerLocation == null) return;
    _selectedVehicle ??= MockData.vehicles.first;
    final requestId = ++_requestGeneration;
    _tripState = TripState.requesting;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 4));
    if (requestId != _requestGeneration || _tripState != TripState.requesting) {
      return;
    }

    _assignedDriver = Driver(
      id: 'driver_001',
      name: 'Carlos Manuel',
      photoUrl: '',
      rating: 4.9,
      vehicleModel: _selectedVehicle!.vehicleModel,
      licensePlate: 'LD-45-23-XX',
    );
    _tripState = TripState.driverFound;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    if (requestId != _requestGeneration || _tripState != TripState.driverFound) {
      return;
    }
    _tripState = TripState.driverArriving;
    notifyListeners();
    _startDriverTracking(requestId);
  }

  void _startDriverTracking(int requestId) {
    final pickup = _passengerLocation;
    final destination = _destination;
    if (pickup == null) return;
    _driverSub?.cancel();
    _driverSub = _driverRepo
        .getDriverLocation(
          'driver_001',
          targetLatitude: pickup.latitude,
          targetLongitude: pickup.longitude,
          dropoffLatitude: destination?.latitude,
          dropoffLongitude: destination?.longitude,
        )
        .listen((location) {
          _driverLocation = location;
          if (_tripState == TripState.driverArriving &&
              (_distance(
                    location.latitude,
                    location.longitude,
                    pickup.latitude,
                    pickup.longitude,
                  ) <
                  0.0007)) {
            _tripState = TripState.driverArrived;
            notifyListeners();
            Future.delayed(const Duration(seconds: 2), () {
              if (requestId == _requestGeneration &&
                  _tripState == TripState.driverArrived) {
                _tripState = TripState.tripStarted;
                notifyListeners();
              }
            });
            return;
          }
          if (_tripState == TripState.driverArrived ||
              _tripState == TripState.tripStarted) {
            if (_destination != null &&
                _distance(
                      location.latitude,
                      location.longitude,
                      _destination!.latitude,
                      _destination!.longitude,
                    ) <
                    0.0007) {
              _driverSub?.cancel();
            }
          }
          notifyListeners();
        });
  }

  LatLng? get _trackingTarget =>
      _tripState == TripState.tripStarted && _destination != null
      ? LatLng(_destination!.latitude, _destination!.longitude)
      : _passengerLocation;

  double _distance(double lat1, double lng1, double lat2, double lng2) =>
      sqrt(pow(lat2 - lat1, 2) + pow(lng2 - lng1, 2));

  void cancelRequest() {
    _requestGeneration++;
    _driverSub?.cancel();
    _tripState = TripState.cancelled;
    _assignedDriver = null;
    _driverLocation = null;
    notifyListeners();
  }

  void completeTrip() {
    _requestGeneration++;
    _driverSub?.cancel();
    final destination = _destination;
    final fare = estimatedFare;
    if (destination != null && fare != null) {
      _tripHistory.insert(
        0,
        Trip(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          origin: 'Minha localização',
          destination: destination.name,
          date: DateTime.now(),
          value: fare,
          paymentMethod: 'Dinheiro',
          status: 'Concluída',
          category: _selectedVehicle?.name ?? 'Executivo',
        ),
      );
    }
    _tripState = TripState.tripCompleted;
    notifyListeners();
  }

  void resetToIdle() {
    _requestGeneration++;
    _driverSub?.cancel();
    _tripState = TripState.idle;
    _destination = null;
    _assignedDriver = null;
    _driverLocation = null;
    _selectedVehicle = null;
    _selectedZone = null;
    _isPickingDestination = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _driverSub?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }
}
