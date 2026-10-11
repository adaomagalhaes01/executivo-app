import 'car_attributes.dart';
import 'car_availability.dart';
import 'car_rules.dart';
import 'rental_location.dart';
import 'rental_owner.dart';
import 'rental_pricing.dart';
import 'vehicle_image.dart';

/// A vehicle available for rent in the Rent a Car module.
///
/// Every listing owns a list of [VehicleImage]s — never a single delimited
/// string — and exposes [coverImage] so cards, details, bookings and owner
/// management screens all render the same hero photograph.
class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
    required this.mileageKm,
    required this.transmission,
    required this.fuel,
    required this.seats,
    required this.pricing,
    required this.location,
    required this.images,
    required this.owner,
    this.description = '',
    this.features = const [],
    this.rules = const CarRules(),
    this.availability = const CarAvailability(),
    this.rating = 0,
    this.reviewsCount = 0,
    this.status = CarStatus.active,
    this.isFavorite = false,
    this.createdAt,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final String color;
  final int mileageKm;
  final TransmissionType transmission;
  final FuelType fuel;
  final int seats;
  final RentalPricing pricing;
  final RentalLocation location;
  final List<VehicleImage> images;
  final RentalOwner owner;

  final String description;
  final List<String> features;
  final CarRules rules;
  final CarAvailability availability;

  final double rating;
  final int reviewsCount;
  final CarStatus status;
  final bool isFavorite;
  final DateTime? createdAt;

  /// `Toyota Corolla`
  String get title => '$brand $model';

  /// The photograph used as the card hero. Falls back to the first image so a
  /// listing never renders an empty frame.
  VehicleImage? get coverImage {
    if (images.isEmpty) return null;
    for (final image in images) {
      if (image.isCover) return image;
    }
    return images.first;
  }

  /// Cover first, then the remaining angles — the order used by the gallery.
  List<VehicleImage> get gallery {
    final cover = coverImage;
    if (cover == null) return const [];
    return [cover, ...images.where((image) => image.id != cover.id)];
  }

  bool get hasPhotos => images.isNotEmpty;

  bool get isAvailable =>
      status == CarStatus.active && availability.isAvailable;

  /// `2024 · Automático · Gasolina · 5 lug.`
  String get specsLabel =>
      '$year · ${transmission.label} · ${fuel.label} · $seats lug.';

  bool get isElectric => fuel == FuelType.electric;

  /// True when the vehicle runs on anything other than pure electricity.
  bool get hasCombustionEngine => fuel != FuelType.electric;

  /// Year and colour, used by the owner management cards.
  String get ageLabel => '$year · $color';

  Car copyWith({
    String? plate,
    int? mileageKm,
    RentalPricing? pricing,
    RentalLocation? location,
    List<VehicleImage>? images,
    CarRules? rules,
    CarAvailability? availability,
    CarStatus? status,
    double? rating,
    int? reviewsCount,
    bool? isFavorite,
    String? description,
    List<String>? features,
    int? seats,
    TransmissionType? transmission,
    FuelType? fuel,
    int? year,
    String? color,
  }) {
    return Car(
      id: id,
      brand: brand,
      model: model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      mileageKm: mileageKm ?? this.mileageKm,
      transmission: transmission ?? this.transmission,
      fuel: fuel ?? this.fuel,
      seats: seats ?? this.seats,
      pricing: pricing ?? this.pricing,
      location: location ?? this.location,
      images: images ?? this.images,
      owner: owner,
      description: description ?? this.description,
      features: features ?? this.features,
      rules: rules ?? this.rules,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  /// Distinct brands present in a catalogue, used by the filter sheet.
  static List<String> brandsOf(List<Car> cars) {
    final brands = cars.map((car) => car.brand).toSet().toList()..sort();
    return brands;
  }

  static List<String> modelsOf(List<Car> cars, String brand) {
    final models = cars
        .where((car) => car.brand == brand)
        .map((car) => car.model)
        .toSet()
        .toList()
      ..sort();
    return models;
  }
}

/// Body-style grouping used by the "type" row on the filter sheet.
enum CarBodyType { sedan, suv, pickup, hatchback, van }

/// Portuguese labels for [CarBodyType].
extension CarBodyTypeX on CarBodyType {
  String get label => switch (this) {
        CarBodyType.sedan => 'Sedã',
        CarBodyType.suv => 'SUV',
        CarBodyType.pickup => 'Pick-up',
        CarBodyType.hatchback => 'Hatchback',
        CarBodyType.van => 'Carrinha',
      };
}