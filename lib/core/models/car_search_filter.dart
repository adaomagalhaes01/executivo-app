import 'car.dart';
import 'car_attributes.dart';
import 'rental_location.dart';

/// The trip the renter is searching for: where, when and how long.
class CarSearchCriteria {
  const CarSearchCriteria({
    this.location,
    this.pickupDate,
    this.returnDate,
    this.withDelivery = false,
  });

  final RentalLocation? location;
  final DateTime? pickupDate;
  final DateTime? returnDate;

  /// Renter asked for the vehicle to be brought to them.
  final bool withDelivery;

  bool get hasDates =>
      pickupDate != null && returnDate != null && days > 0;

  /// Number of rental days, always at least 1 once dates are picked.
  int get days {
    final start = pickupDate;
    final end = returnDate;
    if (start == null || end == null) return 0;
    final diff = DateTime(end.year, end.month, end.day)
        .difference(DateTime(start.year, start.month, start.day))
        .inDays;
    return diff < 1 ? 1 : diff;
  }

  CarSearchCriteria copyWith({
    RentalLocation? location,
    DateTime? pickupDate,
    DateTime? returnDate,
    bool? withDelivery,
    bool clearDates = false,
  }) {
    return CarSearchCriteria(
      location: location ?? this.location,
      pickupDate: clearDates ? null : (pickupDate ?? this.pickupDate),
      returnDate: clearDates ? null : (returnDate ?? this.returnDate),
      withDelivery: withDelivery ?? this.withDelivery,
    );
  }
}

/// Inclusive price window in Kwanza.
class PriceRange {
  const PriceRange({this.min, this.max});

  final double? min;
  final double? max;

  static const PriceRange unbounded = PriceRange();

  bool get isUnbounded => min == null && max == null;

  bool contains(double value) {
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    return true;
  }

  String get label {
    if (isUnbounded) return 'Qualquer preço';
    if (min != null && max != null) return 'Até ${max!.round()} Kz / dia';
    if (max != null) return 'Até ${max!.round()} Kz / dia';
    return 'A partir de ${min!.round()} Kz / dia';
  }

  PriceRange copyWith({
    double? min,
    double? max,
    bool clearMin = false,
    bool clearMax = false,
  }) {
    return PriceRange(
      min: clearMin ? null : (min ?? this.min),
      max: clearMax ? null : (max ?? this.max),
    );
  }
}

/// Everything the filter sheet can narrow down.
///
/// Immutable so the results screen can diff against the previous value and
/// animate only when something actually changed.
class CarSearchFilter {
  const CarSearchFilter({
    this.price = PriceRange.unbounded,
    this.brands = const {},
    this.models = const {},
    this.transmissions = const {},
    this.fuels = const {},
    this.seats = const {},
    this.neighbourhoods = const {},
    this.features = const {},
    this.onlyAvailable = false,
  });

  final PriceRange price;
  final Set<String> brands;
  final Set<String> models;
  final Set<TransmissionType> transmissions;
  final Set<FuelType> fuels;
  final Set<int> seats;
  final Set<String> neighbourhoods;
  final Set<String> features;

  /// When true, vehicles that are paused, rented or have the period blocked
  /// are hidden from the results.
  final bool onlyAvailable;

  bool get isEmpty =>
      price.isUnbounded &&
      brands.isEmpty &&
      models.isEmpty &&
      transmissions.isEmpty &&
      fuels.isEmpty &&
      seats.isEmpty &&
      neighbourhoods.isEmpty &&
      features.isEmpty &&
      !onlyAvailable;

  /// Number of active filters — rendered as the badge on the filter button.
  int get activeCount {
    var count = 0;
    if (!price.isUnbounded) count++;
    count += brands.length;
    count += models.length;
    count += transmissions.length;
    count += fuels.length;
    count += seats.length;
    count += neighbourhoods.length;
    count += features.length;
    if (onlyAvailable) count++;
    return count;
  }

  bool matches(Car car, CarSearchCriteria criteria) {
    if (!price.contains(car.pricing.pricePerDay)) return false;
    if (brands.isNotEmpty && !brands.contains(car.brand)) return false;
    if (models.isNotEmpty && !models.contains(car.model)) return false;
    if (transmissions.isNotEmpty && !transmissions.contains(car.transmission)) {
      return false;
    }
    if (fuels.isNotEmpty && !fuels.contains(car.fuel)) return false;
    if (seats.isNotEmpty && !seats.contains(car.seats)) return false;
    if (neighbourhoods.isNotEmpty &&
        !neighbourhoods.contains(car.location.label)) {
      return false;
    }
    if (features.isNotEmpty &&
        !car.features.any((feature) => features.contains(feature))) {
      return false;
    }
    if (onlyAvailable) {
      if (!car.isAvailable) return false;
      final pickup = criteria.pickupDate;
      final dropOff = criteria.returnDate;
      if (pickup != null &&
          dropOff != null &&
          !car.availability.isRangeFree(pickup, dropOff)) {
        return false;
      }
    }
    return true;
  }

  CarSearchFilter copyWith({
    PriceRange? price,
    Set<String>? brands,
    Set<String>? models,
    Set<TransmissionType>? transmissions,
    Set<FuelType>? fuels,
    Set<int>? seats,
    Set<String>? neighbourhoods,
    Set<String>? features,
    bool? onlyAvailable,
  }) {
    return CarSearchFilter(
      price: price ?? this.price,
      brands: brands ?? this.brands,
      models: models ?? this.models,
      transmissions: transmissions ?? this.transmissions,
      fuels: fuels ?? this.fuels,
      seats: seats ?? this.seats,
      neighbourhoods: neighbourhoods ?? this.neighbourhoods,
      features: features ?? this.features,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }

  static const CarSearchFilter none = CarSearchFilter();
}