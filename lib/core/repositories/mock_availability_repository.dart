import '../data/mock_rentacar_data.dart';
import '../models/car.dart';
import '../models/car_availability.dart';
import 'availability_repository.dart';

/// In-memory availability store seeded from the bundled catalogue.
class MockAvailabilityRepository implements AvailabilityRepository {
  MockAvailabilityRepository({List<Car>? seed})
      : _store = {
          for (final car in seed ?? MockRentCarData.cars) car.id: car,
        };

  static const Duration _latency = Duration(milliseconds: 260);

  final Map<String, Car> _store;

  Future<void> _delay() => Future<void>.delayed(_latency);

  Car _require(String carId) {
    final car = _store[carId];
    if (car == null) throw StateError('Veículo não encontrado: $carId');
    return car;
  }

  @override
  Future<Car> fetchAvailability(String carId) async {
    await _delay();
    return _require(carId);
  }

  @override
  Future<Car> saveAvailability(
    String carId,
    bool isAvailable,
    List<DateTime> blockedDates,
  ) async {
    await _delay();
    final car = _require(carId);
    final updated = car.copyWith(
      availability: car.availability.copyWith(
        status: isAvailable
            ? AvailabilityStatus.available
            : AvailabilityStatus.unavailable,
        blockedPeriods: _groupIntoPeriods(blockedDates),
      ),
    );
    _store[carId] = updated;
    return updated;
  }

  @override
  Future<List<DateTime>> addBlockedRange(
    String carId, {
    required DateTime start,
    required DateTime end,
  }) async {
    await _delay();
    final car = _require(carId);
    final dates = _flatten(car.availability.blockedPeriods)
      ..addAll(_daysBetween(start, end))
      ..sort();
    return _dedupe(dates);
  }

  @override
  Future<List<DateTime>> removeBlockedDate(String carId, DateTime date) async {
    await _delay();
    final car = _require(carId);
    final dates = _flatten(car.availability.blockedPeriods)
      ..removeWhere((day) => _sameDay(day, date))
      ..sort();
    return _dedupe(dates);
  }

  @override
  Future<bool> isRangeAvailable(
    String carId, {
    required DateTime start,
    required DateTime end,
  }) async {
    await _delay();
    final car = _store[carId];
    return car == null || car.availability.isRangeFree(start, end);
  }

  // ─── Date helpers ──────────────────────────────────────────────────────────

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<DateTime> _daysBetween(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  static List<DateTime> _flatten(List<BlockedPeriod> periods) => periods
      .expand((period) => _daysBetween(period.start, period.end))
      .toList();

  static List<DateTime> _dedupe(List<DateTime> dates) {
    final seen = <String>{};
    return dates.where((day) => seen.add('${day.year}-${day.month}-${day.day}'))
        .toList();
  }

  /// Collapses a flat list of blocked days into contiguous [BlockedPeriod]s.
  static List<BlockedPeriod> _groupIntoPeriods(List<DateTime> dates) {
    if (dates.isEmpty) return const [];
    final sorted = [...dates]..sort();
    final periods = <BlockedPeriod>[];
    var start = sorted.first;
    var end = sorted.first;
    for (final date in sorted.skip(1)) {
      if (date.difference(end).inDays == 1) {
        end = date;
      } else {
        periods.add(BlockedPeriod(start: start, end: end));
        start = date;
        end = date;
      }
    }
    periods.add(BlockedPeriod(start: start, end: end));
    return periods;
  }
}