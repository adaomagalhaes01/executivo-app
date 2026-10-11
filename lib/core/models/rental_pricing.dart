/// Daily / weekly / monthly rates of a vehicle plus the optional extras that
/// are added on top of the daily rate when a booking is priced.
///
/// Nothing is assumed: every fee defaults to zero so a listing that does not
/// configure a service fee is never charged one.
class RentalPricing {
  const RentalPricing({
    required this.pricePerDay,
    this.pricePerWeek,
    this.pricePerMonth,
    this.serviceFee = 0,
    this.deliveryFee = 0,
    this.deposit = 0,
  });

  final double pricePerDay;
  final double? pricePerWeek;
  final double? pricePerMonth;

  /// Flat fee added once per booking.
  final double serviceFee;

  /// Charged when the vehicle is delivered instead of collected in person.
  final double deliveryFee;

  /// Refundable amount held for the duration of the rental.
  final double deposit;

  /// Effective price of a single day, honouring the weekly and monthly
  /// rates when the requested period is long enough.
  double effectiveDailyRate(int days) {
    if (days <= 0) return pricePerDay;
    if (pricePerMonth != null && days >= 28) return pricePerMonth! / 28;
    if (pricePerWeek != null && days >= 7) return pricePerWeek! / 7;
    return pricePerDay;
  }

  /// Full breakdown for a booking of [days] days.
  RentalQuote quote({required int days, bool withDelivery = false}) {
    if (days <= 0) return RentalQuote.empty;
    final rate = effectiveDailyRate(days);
    final subtotal = rate * days;
    final fees = serviceFee + (withDelivery ? deliveryFee : 0);
    return RentalQuote(
      days: days,
      dailyRate: rate,
      subtotal: subtotal,
      fees: fees,
      deposit: deposit,
      total: subtotal + fees,
    );
  }

  RentalPricing copyWith({
    double? pricePerDay,
    double? pricePerWeek,
    double? pricePerMonth,
    double? serviceFee,
    double? deliveryFee,
    double? deposit,
  }) {
    return RentalPricing(
      pricePerDay: pricePerDay ?? this.pricePerDay,
      pricePerWeek: pricePerWeek ?? this.pricePerWeek,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      serviceFee: serviceFee ?? this.serviceFee,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deposit: deposit ?? this.deposit,
    );
  }
}

/// Immutable price breakdown shown on the booking and confirmation screens.
class RentalQuote {
  const RentalQuote({
    required this.days,
    required this.dailyRate,
    required this.subtotal,
    required this.fees,
    required this.deposit,
    required this.total,
  });

  static const RentalQuote empty = RentalQuote(
    days: 0,
    dailyRate: 0,
    subtotal: 0,
    fees: 0,
    deposit: 0,
    total: 0,
  );

  final int days;
  final double dailyRate;
  final double subtotal;
  final double fees;

  /// Refundable — reported separately, never added to [total].
  final double deposit;

  /// Amount actually charged: [subtotal] + [fees].
  final double total;

  bool get hasFees => fees > 0;
  bool get hasDeposit => deposit > 0;
}

/// Validation helpers for the rates step of the listing wizard.
///
/// They never invent a value — they only reject malformed or inconsistent
/// input so the owner stays in control of the numbers.
class PricingValidation {
  static double? parseAmount(String? raw) =>
      double.tryParse((raw ?? '').replaceAll(RegExp(r'[^0-9.]'), ''));

  static String? pricePerDayError(String? raw) {
    final value = parseAmount(raw);
    if (value == null) return 'Indique o preço por dia';
    if (value <= 0) return 'O preço deve ser maior que zero';
    return null;
  }

  static String? weeklyError(String? raw, double daily) {
    if ((raw ?? '').trim().isEmpty) return null;
    final value = parseAmount(raw);
    if (value == null || value <= 0) return 'Valor inválido';
    if (value < daily * 5) return 'Muito abaixo do preço diário';
    return null;
  }

  static String? monthlyError(String? raw, double daily) {
    if ((raw ?? '').trim().isEmpty) return null;
    final value = parseAmount(raw);
    if (value == null || value <= 0) return 'Valor inválido';
    if (value < daily * 22) return 'Muito abaixo do preço diário';
    return null;
  }
}