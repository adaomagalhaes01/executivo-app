import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> get isServiceEnabled => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> get permission => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    return status;
  }

  Future<Position?> getCurrentLocation() async {
    if (!await isServiceEnabled) return null;
    final status = await requestPermission();
    if (status == LocationPermission.denied ||
        status == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Stream<Position> watchPosition() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );
}
