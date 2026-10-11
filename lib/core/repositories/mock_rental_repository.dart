import '../data/mock_rentacar_data.dart';
import '../models/car.dart';
import '../models/rental.dart';
import '../models/rental_pricing.dart';
import '../models/rental_request.dart';
import 'rental_repository.dart';

/// In-memory booking store seeded with a couple of examples so the rental
/// screens are never empty on first launch.
class MockRentalRepository implements RentalRepository {
  MockRentalRepository({List<Rental>? seed})
      : _store = [...seed ?? _buildSeeds()];

  static const Duration _latency = Duration(milliseconds: 380);

  final List<Rental> _store;

  static const String _renterId = 'renter_current';

  static List<Rental> _buildSeeds() {
    final now = DateTime.now();

    Car carById(String id) =>
        MockRentCarData.cars.firstWhere((car) => car.id == id);

    final corolla = carById('car_corolla');
    final cclass = carById('car_cclass');
    final hiace = carById('car_hiace');

    final upcomingPickup = DateTime(now.year, now.month, now.day + 3, 9);
    final upcomingReturn = DateTime(now.year, now.month, now.day + 6, 18);

    final pastPickup = DateTime(now.year, now.month, now.day - 12, 10);
    final pastReturn = DateTime(now.year, now.month, now.day - 9, 18);

    return [
      Rental(
        id: 'rental_upcoming',
        car: corolla,
        pickupDate: upcomingPickup,
        returnDate: upcomingReturn,
        quote: corolla.pricing.quote(days: 3),
        status: RentalStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Rental(
        id: 'rental_past',
        car: cclass,
        pickupDate: pastPickup,
        returnDate: pastReturn,
        quote: cclass.pricing.quote(days: 3),
        status: RentalStatus.completed,
        createdAt: pastPickup.subtract(const Duration(days: 6)),
      ),
      Rental(
        id: 'rental_waiting',
        car: hiace,
        pickupDate: DateTime(now.year, now.month, now.day + 5, 8),
        returnDate: DateTime(now.year, now.month, now.day + 7, 19),
        quote: hiace.pricing.quote(days: 2),
        status: RentalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 20)),
      ),
    ];
  }

  Future<void> _delay() => Future<void>.delayed(_latency);

  @override
  Future<List<Rental>> fetchRentalsOfRenter(String renterId) async {
    await _delay();
    final list = List<Rental>.from(_store)
      ..sort((a, b) => b.pickupDate.compareTo(a.pickupDate));
    return list;
  }

  @override
  Future<List<RentalRequest>> fetchRequestsOfOwner(String ownerId) async {
    await _delay();
    final requests = _store
        .where((rental) => rental.car.owner.id == ownerId)
        .map(_toRequest)
        .toList()
      ..sort((a, b) => b.rental.createdAt.compareTo(a.rental.createdAt));
    return requests;
  }

  @override
  Future<Rental?> fetchById(String rentalId) async {
    await _delay();
    for (final rental in _store) {
      if (rental.id == rentalId) return rental;
    }
    return null;
  }

  @override
  Future<Rental> createRequest(Rental rental) async {
    await _delay();
    _store.insert(0, rental);
    return rental;
  }

  @override
  Future<Rental> updateStatus(String rentalId, RentalStatus status) async {
    await _delay();
    final index = _store.indexWhere((rental) => rental.id == rentalId);
    if (index < 0) throw StateError('Reserva não encontrada: $rentalId');
    final updated = _store[index].copyWith(status: status);
    _store[index] = updated;
    return updated;
  }

  /// Builds the owner-facing view of a booking, attaching a renter profile.
  RentalRequest _toRequest(Rental rental) {
    final profiles = <String, RentalRenter>{
      'renter_current': const RentalRenter(
        name: 'Adão Magalhães',
        rating: 4.9,
        reviewCount: 7,
        phone: '+244 923 000 111',
        isVerified: true,
      ),
      'renter_joao': const RentalRenter(
        name: 'João Pedro',
        rating: 4.6,
        reviewCount: 12,
        phone: '+244 934 222 333',
      ),
      'renter_marta': const RentalRenter(
        name: 'Marta Bengui',
        rating: 5.0,
        reviewCount: 3,
        phone: '+244 945 555 666',
        isVerified: true,
      ),
    };
    final key = rental.id == 'rental_upcoming' ||
            rental.id == 'rental_past' ||
            rental.id == 'rental_waiting'
        ? 'renter_current'
        : 'renter_joao';
    return RentalRequest(
      id: 'request_${rental.id}',
      rental: rental,
      renter: profiles[key]!,
      note: rental.status == RentalStatus.pending
          ? 'Bom dia, precisamos da carrinha para uma deslocação de grupo.'
          : '',
    );
  }

  /// `Toyota Corolla` — convenience for the booking screen.
  static RentalQuote quoteFor(Car car, int days) =>
      car.pricing.quote(days: days);

  /// The signed-in user identifier used by the mock layer.
  static String get renterId => _renterId;
}