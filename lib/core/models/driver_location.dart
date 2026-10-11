class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final double heading;
  final double speed;
  final double accuracy;
  final DateTime timestamp;

  DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
  });
}
