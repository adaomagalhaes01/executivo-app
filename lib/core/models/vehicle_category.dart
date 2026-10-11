class VehicleCategory {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final int etaMinutes;
  final double priceMultiplier;
  final String vehicleModel;

  const VehicleCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.etaMinutes,
    required this.priceMultiplier,
    required this.vehicleModel,
  });
}
