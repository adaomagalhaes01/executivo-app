import 'car_attributes.dart';
import 'car_availability.dart';
import 'car_rules.dart';
import 'rental_location.dart';
import 'rental_pricing.dart';
import 'vehicle_image.dart';

/// The six steps of the "Colocar meu carro para alugar" wizard.
enum PublishStep { vehicle, photos, pricing, availability, location, rules, review }

extension PublishStepX on PublishStep {
  String get title => switch (this) {
        PublishStep.vehicle => 'O seu veículo',
        PublishStep.photos => 'Fotos do carro',
        PublishStep.pricing => 'Preço',
        PublishStep.availability => 'Disponibilidade',
        PublishStep.location => 'Local de levantamento',
        PublishStep.rules => 'Regras do aluguer',
        PublishStep.review => 'Rever anúncio',
      };

  String get subtitle => switch (this) {
        PublishStep.vehicle => 'Conte-nos sobre o carro',
        PublishStep.photos => 'A primeira foto é a capa',
        PublishStep.pricing => 'Defina os seus valores',
        PublishStep.availability => 'Escolha quando pode alugar',
        PublishStep.location => 'Onde o cliente levanta o carro',
        PublishStep.rules => 'Termos do aluguer',
        PublishStep.review => 'Está tudo certo?',
      };

  /// Review is only reachable once every previous step is valid.
  bool get isRequired => this != PublishStep.review;
}

/// Writable state of the publish wizard.
///
/// Everything the owner types lives here — one immutable object the wizard
/// mutates step by step — so "Rever anúncio" can render the real listing data
/// instead of a separate preview copy.
class CarListingDraft {
  const CarListingDraft({
    this.brand = '',
    this.model = '',
    this.year,
    this.plate = '',
    this.color = '',
    this.mileageKm,
    this.transmission,
    this.fuel,
    this.seats,
    this.images = const [],
    this.pricePerDay,
    this.pricePerWeek,
    this.pricePerMonth,
    this.serviceFee,
    this.deposit,
    this.availability = const CarAvailability(),
    this.location,
    this.rules = const CarRules(),
    this.description = '',
    this.features = const [],
    this.currentStep = PublishStep.vehicle,
  });

  // ─── Step 1 — Vehicle ──────────────────────────────────────────────────────
  final String brand;
  final String model;
  final int? year;
  final String plate;
  final String color;
  final int? mileageKm;
  final TransmissionType? transmission;
  final FuelType? fuel;
  final int? seats;

  // ─── Step 2 — Photos ───────────────────────────────────────────────────────
  final List<VehicleImage> images;

  // ─── Step 3 — Pricing ──────────────────────────────────────────────────────
  final double? pricePerDay;
  final double? pricePerWeek;
  final double? pricePerMonth;
  final double? serviceFee;
  final double? deposit;

  // ─── Step 4 — Availability ─────────────────────────────────────────────────
  final CarAvailability availability;

  // ─── Step 5 — Location ─────────────────────────────────────────────────────
  final RentalLocation? location;

  // ─── Step 6 — Rules ────────────────────────────────────────────────────────
  final CarRules rules;

  final String description;
  final List<String> features;
  final PublishStep currentStep;

  /// At least one photograph is mandatory before publishing.
  bool get hasCoverPhoto => images.any((image) => image.isCover);

  bool get hasAnyPhoto => images.isNotEmpty;

  int get photoCount => images.length;

  /// Percentage of required steps already satisfied — drives the step header.
  double get completion {
    var done = 0;
    if (isVehicleValid) done++;
    if (hasCoverPhoto) done++;
    if (isPricingValid) done++;
    if (isAvailabilityValid) done++;
    if (isLocationValid) done++;
    if (isRulesValid) done++;
    return done / 6;
  }

  int get completedRequiredSteps {
    var done = 0;
    if (isVehicleValid) done++;
    if (hasCoverPhoto) done++;
    if (isPricingValid) done++;
    if (isAvailabilityValid) done++;
    if (isLocationValid) done++;
    if (isRulesValid) done++;
    return done;
  }

  // ─── Per-step validation ───────────────────────────────────────────────────

  bool get isVehicleValid =>
      brand.trim().isNotEmpty &&
      model.trim().isNotEmpty &&
      year != null &&
      (year! >= 1990 && year! <= 2060) &&
      plate.trim().isNotEmpty &&
      color.trim().isNotEmpty &&
      mileageKm != null &&
      mileageKm! >= 0 &&
      transmission != null &&
      fuel != null &&
      seats != null;

  bool get isPricingValid => (pricePerDay ?? 0) > 0;

  /// Any availability choice is valid; blocking dates is optional.
  bool get isAvailabilityValid => true;

  bool get isLocationValid => location != null && location!.address.isNotEmpty;

  /// Rules are entirely owner-configured, so the step is always passable.
  bool get isRulesValid => true;

  bool isStepValid(PublishStep step) => switch (step) {
        PublishStep.vehicle => isVehicleValid,
        PublishStep.photos => hasCoverPhoto,
        PublishStep.pricing => isPricingValid,
        PublishStep.availability => isAvailabilityValid,
        PublishStep.location => isLocationValid,
        PublishStep.rules => isRulesValid,
        PublishStep.review => true,
      };

  /// Validation message shown when the owner tries to skip ahead.
  String? blockingMessage(PublishStep step) => switch (step) {
        PublishStep.vehicle => 'Preencha os dados do veículo para continuar',
        PublishStep.photos => 'Adicione pelo menos uma fotografia',
        PublishStep.pricing => 'Defina o preço por dia',
        PublishStep.availability => null,
        PublishStep.location => 'Escolha o local de levantamento no mapa',
        PublishStep.rules => null,
        PublishStep.review => null,
      };

  /// Builds the immutable [RentalPricing] once the rates are set.
  RentalPricing get pricing => RentalPricing(
        pricePerDay: pricePerDay ?? 0,
        pricePerWeek: pricePerWeek,
        pricePerMonth: pricePerMonth,
        serviceFee: serviceFee ?? 0,
        deposit: deposit ?? 0,
      );

  String get title => brand.trim().isEmpty && model.trim().isEmpty
      ? 'Novo anúncio'
      : '${brand.trim()} ${model.trim()}'.trim();

  VehicleImage? get coverImage {
    for (final image in images) {
      if (image.isCover) return image;
    }
    return images.isEmpty ? null : images.first;
  }

  CarListingDraft copyWith({
    String? brand,
    String? model,
    int? year,
    String? plate,
    String? color,
    int? mileageKm,
    TransmissionType? transmission,
    FuelType? fuel,
    int? seats,
    List<VehicleImage>? images,
    double? pricePerDay,
    double? pricePerWeek,
    double? pricePerMonth,
    double? serviceFee,
    double? deposit,
    CarAvailability? availability,
    RentalLocation? location,
    CarRules? rules,
    String? description,
    List<String>? features,
    PublishStep? currentStep,
    bool clearWeekly = false,
    bool clearMonthly = false,
    bool clearServiceFee = false,
    bool clearDeposit = false,
    bool clearLocation = false,
  }) {
    return CarListingDraft(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      mileageKm: mileageKm ?? this.mileageKm,
      transmission: transmission ?? this.transmission,
      fuel: fuel ?? this.fuel,
      seats: seats ?? this.seats,
      images: images ?? this.images,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      pricePerWeek: clearWeekly ? null : (pricePerWeek ?? this.pricePerWeek),
      pricePerMonth: clearMonthly ? null : (pricePerMonth ?? this.pricePerMonth),
      serviceFee:
          clearServiceFee ? null : (serviceFee ?? this.serviceFee),
      deposit: clearDeposit ? null : (deposit ?? this.deposit),
      availability: availability ?? this.availability,
      location: clearLocation ? null : (location ?? this.location),
      rules: rules ?? this.rules,
      description: description ?? this.description,
      features: features ?? this.features,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}