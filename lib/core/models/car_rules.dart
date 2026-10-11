/// Owner-configured rules attached to a listing.
///
/// Every field is optional and defaults to "not configured" — the module never
/// invents a policy on the owner's behalf. When a value is absent the UI simply
/// omits the corresponding row.
class CarRules {
  const CarRules({
    this.dailyKilometreLimit,
    this.extraKilometrePrice,
    this.deposit,
    this.minimumAge,
    this.requiredDocuments = const [],
    this.fuelPolicy,
    this.cancellationPolicy,
    this.notes = '',
  });

  /// Free kilometres included in each rental day.
  final int? dailyKilometreLimit;

  /// Price charged for every kilometre beyond the allowance.
  final double? extraKilometrePrice;

  /// Refundable deposit. Kept here as a display copy of
  /// [RentalPricing.deposit] so the rules block stays self-contained.
  final double? deposit;

  final int? minimumAge;

  /// Documents the renter must present, e.g. `Carta de Condução`.
  final List<String> requiredDocuments;

  /// Free text fuel policy ("Depósito cheio para cheio").
  final String? fuelPolicy;

  /// Free text cancellation policy.
  final String? cancellationPolicy;

  /// Anything the owner wants to add beyond the structured fields.
  final String notes;

  bool get isEmpty =>
      dailyKilometreLimit == null &&
      extraKilometrePrice == null &&
      deposit == null &&
      minimumAge == null &&
      requiredDocuments.isEmpty &&
      (fuelPolicy == null || fuelPolicy!.isEmpty) &&
      (cancellationPolicy == null || cancellationPolicy!.isEmpty) &&
      notes.isEmpty;

  CarRules copyWith({
    int? dailyKilometreLimit,
    double? extraKilometrePrice,
    double? deposit,
    int? minimumAge,
    List<String>? requiredDocuments,
    String? fuelPolicy,
    String? cancellationPolicy,
    String? notes,
  }) {
    return CarRules(
      dailyKilometreLimit: dailyKilometreLimit ?? this.dailyKilometreLimit,
      extraKilometrePrice: extraKilometrePrice ?? this.extraKilometrePrice,
      deposit: deposit ?? this.deposit,
      minimumAge: minimumAge ?? this.minimumAge,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      fuelPolicy: fuelPolicy ?? this.fuelPolicy,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      notes: notes ?? this.notes,
    );
  }
}