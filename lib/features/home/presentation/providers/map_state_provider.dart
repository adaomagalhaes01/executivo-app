import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/models/driver_location.dart';

class MapStateProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _passengerLatLng;
  _PlaceResultLatLng? _destinationLatLng;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng? _animatedDriverLatLng;
  DriverLocation? _driverLocation;
  Timer? _animationTimer;

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

  void setMapController(GoogleMapController ctrl) {
    _mapController = ctrl;
    if (_passengerLatLng != null) moveCamera(_passengerLatLng!, zoom: 15);
  }

  void updatePassengerLocation(LatLng location) {
    _passengerLatLng = location;
    _rebuildMarkers();
    _rebuildRoute();
    if (_mapController != null) moveCamera(location, zoom: 15);
  }

  void updateDestination(double lat, double lng, String name) {
    _destinationLatLng = _PlaceResultLatLng(lat: lat, lng: lng, name: name);
    _rebuildMarkers();
    _rebuildRoute();
  }

  void clearDestination() {
    _destinationLatLng = null;
    _polylines.clear();
    _rebuildMarkers();
  }

  void updateDriverLocation(DriverLocation driverLoc) {
    final newLatLng = LatLng(driverLoc.latitude, driverLoc.longitude);
    if (_animatedDriverLatLng == null) {
      _animatedDriverLatLng = newLatLng;
      _driverLocation = driverLoc;
      _rebuildMarkers();
      _fitDriverAndPassenger(newLatLng);
      return;
    }
    _animateDriverTo(newLatLng, driverLoc);
  }

  void _animateDriverTo(LatLng target, DriverLocation driverLoc) {
    _animationTimer?.cancel();
    final LatLng start = _animatedDriverLatLng ?? target;
    const steps = 20;
    int step = 0;

    _animationTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      step++;
      if (step >= steps) {
        _animatedDriverLatLng = target;
        _driverLocation = driverLoc;
        _rebuildMarkers();
        t.cancel();
        return;
      }
      final fraction = step / steps;
      final lat = start.latitude + (target.latitude - start.latitude) * fraction;
      final lng = start.longitude + (target.longitude - start.longitude) * fraction;
      _animatedDriverLatLng = LatLng(lat, lng);
      _driverLocation = driverLoc;
      _rebuildMarkers();
    });
  }

  void clearDriver() {
    _animationTimer?.cancel();
    _animatedDriverLatLng = null;
    _driverLocation = null;
    _markers.removeWhere((m) => m.markerId.value == 'driver');
    _polylines.removeWhere((p) => p.polylineId.value == 'driver_route');
    notifyListeners();
  }

  void _rebuildMarkers() {
    _markers.clear();

    if (_passengerLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('passenger'),
        position: _passengerLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'A minha localização'),
      ));
    }

    if (_destinationLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(_destinationLatLng!.lat, _destinationLatLng!.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: _destinationLatLng!.name),
      ));
    }

    if (_animatedDriverLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _animatedDriverLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        rotation: _driverLocation?.heading ?? 0,
        infoWindow: const InfoWindow(title: 'Motorista'),
        anchor: const Offset(0.5, 0.5),
      ));
    }

    notifyListeners();
  }

  void _rebuildRoute() {
    _polylines.removeWhere((p) => p.polylineId.value == 'route');
    if (_passengerLatLng == null || _destinationLatLng == null) return;

    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: [
        _passengerLatLng!,
        LatLng(_destinationLatLng!.lat, _destinationLatLng!.lng),
      ],
      color: const Color(0xFFE8000D),
      width: 5,
    ));

    _fitBounds();
    notifyListeners();
  }

  void addDriverRoute(LatLng driverPos, {LatLng? destination}) {
    final target = destination ?? _passengerLatLng;
    if (target == null) return;
    _polylines.removeWhere((p) => p.polylineId.value == 'driver_route');
    _polylines.add(Polyline(
      polylineId: const PolylineId('driver_route'),
      points: [driverPos, target],
      color: const Color(0xFF667085),
      width: 4,
      patterns: [PatternItem.dash(16), PatternItem.gap(8)],
    ));
    notifyListeners();
  }

  void _fitDriverAndPassenger(LatLng driverPosition) {
    if (_passengerLatLng == null || _mapController == null) return;
    final pickup = _passengerLatLng!;
    if (pickup.latitude == driverPosition.latitude && pickup.longitude == driverPosition.longitude) {
      moveCamera(pickup, zoom: 15);
      return;
    }
    final southwest = LatLng(
      min(pickup.latitude, driverPosition.latitude),
      min(pickup.longitude, driverPosition.longitude),
    );
    final northeast = LatLng(
      max(pickup.latitude, driverPosition.latitude),
      max(pickup.longitude, driverPosition.longitude),
    );
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        100,
      ),
    );
  }

  void moveCamera(LatLng target, {double zoom = 15}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _fitBounds() {
    if (_passengerLatLng == null || _destinationLatLng == null) return;
    final dest = LatLng(_destinationLatLng!.lat, _destinationLatLng!.lng);
    final sw = LatLng(
      _passengerLatLng!.latitude < dest.latitude ? _passengerLatLng!.latitude : dest.latitude,
      _passengerLatLng!.longitude < dest.longitude ? _passengerLatLng!.longitude : dest.longitude,
    );
    final ne = LatLng(
      _passengerLatLng!.latitude > dest.latitude ? _passengerLatLng!.latitude : dest.latitude,
      _passengerLatLng!.longitude > dest.longitude ? _passengerLatLng!.longitude : dest.longitude,
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(LatLngBounds(southwest: sw, northeast: ne), 80),
    );
  }

  void moveCameraToPassenger() {
    if (_passengerLatLng != null) {
      moveCamera(_passengerLatLng!, zoom: 15);
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}

class _PlaceResultLatLng {
  final double lat;
  final double lng;
  final String name;
  _PlaceResultLatLng({required this.lat, required this.lng, required this.name});
}
