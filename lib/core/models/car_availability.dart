/// Whether a vehicle is currently bookable.
enum AvailabilityStatus { available, unavailable }

/// A contiguous stretch of dates the owner blocked out.
class BlockedPeriod {
  const BlockedPeriod({
    required this.start,
    required this.end,
    this.reason = '',
  });

  final DateTime start;
  final DateTime end;
  final String reason;

  bool contains(DateTime day) {
    final target = _dateOnly(day);
    return !target.isBefore(_dateOnly(start)) && !target.isAfter(_dateOnly(end));
  }

  /// True when [start]..[end] overlaps this blocked period at all.
  bool overlaps(DateTime start, DateTime end) {
    final a = _dateOnly(start);
    final b = _dateOnly(end);
    final s = _dateOnly(this.start);
    final e = _dateOnly(this.end);
    return !b.isBefore(s) && !a.isAfter(e);
  }

  int get nights => _dateOnly(end).difference(_dateOnly(start)).inDays;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Availability of a vehicle: a manual switch plus a list of blocked dates.
///
/// The structure already supports a calendar — blocked ranges are date ranges,
/// so a month-grid UI can be layered on without touching the model.
class CarAvailability {
  const CarAvailability({
    this.status = AvailabilityStatus.available,
    this.blockedPeriods = const [],
    this.minimumNoticeHours = 2,
  });

  final AvailabilityStatus status;

  /// Dates the owner reserved for himself or made unavailable.
  final List<BlockedPeriod> blockedPeriods;

  /// Bookings must start at least this many hours from now.
  final int minimumNoticeHours;

  bool get isAvailable => status == AvailabilityStatus.available;

  bool isBlocked(DateTime day) =>
      blockedPeriods.any((period) => period.contains(day));

  /// True when any day of the requested range is blocked, or when the range
  /// ends before it starts.
  bool isRangeFree(DateTime start, DateTime end) {
    if (end.isBefore(start)) return false;
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (isBlocked(cursor)) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  int get blockedDays => blockedPeriods.fold<int>(
        0,
        (total, period) => total + period.nights,
      );

  CarAvailability copyWith({
    AvailabilityStatus? status,
    List<BlockedPeriod>? blockedPeriods,
    int? minimumNoticeHours,
  }) {
    return CarAvailability(
      status: status ?? this.status,
      blockedPeriods: blockedPeriods ?? this.blockedPeriods,
      minimumNoticeHours: minimumNoticeHours ?? this.minimumNoticeHours,
    );
  }
}