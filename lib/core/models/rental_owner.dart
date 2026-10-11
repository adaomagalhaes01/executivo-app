/// The account that published a vehicle.
class RentalOwner {
  const RentalOwner({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalRentals,
    this.photoUrl = '',
    this.memberSince,
    this.isVerified = false,
    this.responseRate = 100,
    this.typicalResponseMinutes = 15,
  });

  final String id;
  final String name;
  final double rating;

  /// How many rentals this owner has completed — shown as social proof.
  final int totalRentals;

  final String photoUrl;
  final DateTime? memberSince;
  final bool isVerified;

  /// Percentage of messages answered, 0–100.
  final int responseRate;

  /// Typical answer time used in the detail screen.
  final int typicalResponseMinutes;

  /// Initials used by the avatar fallback when [photoUrl] is empty.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}