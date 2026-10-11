import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/mock_data.dart';
import '../../../../core/models/driver.dart';
import '../../../../core/models/trip_state.dart';
import '../../../../core/models/vehicle_category.dart';
import '../providers/map_state_provider.dart';
import '../providers/trip_state_provider.dart';
import 'destination_search_modal.dart';

class TripBottomSheet extends StatelessWidget {
  const TripBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripStateProvider>();
    final state = trip.tripState;
    final Widget content;
    if (state == TripState.requesting) {
      content = _SearchingSheet(onCancel: trip.cancelRequest);
    } else if (state == TripState.driverFound ||
        state == TripState.driverArriving ||
        state == TripState.driverArrived) {
      content = _DriverCard(
        driver: trip.assignedDriver!,
        state: state,
        eta: trip.driverEtaMinutes,
        distance: trip.driverDistanceKm,
        onCancel: trip.cancelRequest,
      );
    } else if (state == TripState.tripStarted) {
      content = _TripInProgress(
        driver: trip.assignedDriver!,
        destination: trip.destination?.name ?? '',
        fare: trip.estimatedFare,
        onComplete: trip.completeTrip,
      );
    } else if (state == TripState.tripCompleted) {
      content = _TripCompleted(
        onNewTrip: () {
          trip.resetToIdle();
          context.read<MapStateProvider>().clearDestination();
        },
      );
    } else if (state == TripState.cancelled) {
      content = _CancelledSheet(
        onNewTrip: () {
          trip.resetToIdle();
          context.read<MapStateProvider>().clearDestination();
        },
      );
    } else if (state == TripState.destinationSelected ||
        state == TripState.vehicleSelected) {
      content = _RideOptionsSheet(
        key: ValueKey(state),
        trip: trip,
        isConfirming: state == TripState.vehicleSelected,
      );
    } else {
      content = _DestinationSheet(trip: trip);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: content,
    );
  }
}

class _SheetFrame extends StatelessWidget {
  final Widget child;
  const _SheetFrame({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .68,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      boxShadow: [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 24,
          offset: Offset(0, -5),
        ),
      ],
    ),
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      16 + MediaQuery.paddingOf(context).bottom,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _DestinationSheet extends StatelessWidget {
  final TripStateProvider trip;
  const _DestinationSheet({required this.trip});

  @override
  Widget build(BuildContext context) => _SheetFrame(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Para onde vamos?',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101820),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escolha um destino para começar a sua viagem.',
          style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final place = await showModalBottomSheet<PlaceResult>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const DestinationSearchModal(),
            );
            if (place != null && context.mounted) {
              trip.setDestination(place);
              context.read<MapStateProvider>().updateDestination(
                place.latitude,
                place.longitude,
                place.name,
              );
            }
          },
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Color(0xFF344054)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pesquisar local ou endereço',
                    style: TextStyle(fontSize: 15, color: Color(0xFF667085)),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFF667085),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.my_location, size: 18, color: Color(0xFF12A05C)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                trip.passengerLocation == null
                    ? 'Localização indisponível'
                    : 'Minha localização',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344054),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: trip.startDestinationMapPick,
              icon: const Icon(Icons.map_outlined, size: 17),
              label: const Text('No mapa'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF101820),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        if (trip.isPickingDestination) ...[
          const SizedBox(height: 8),
          const _HintBanner(text: 'Toque no mapa para marcar o destino.'),
        ],
        const SizedBox(height: 8),
        const Text(
          'Sugestões populares',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 6),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PopularPlace(name: 'Aeroporto', icon: Icons.flight_outlined),
            _PopularPlace(name: 'Talatona', icon: Icons.business_outlined),
            _PopularPlace(name: 'Miramar', icon: Icons.park_outlined),
          ],
        ),
      ],
    ),
  );
}

class _PopularPlace extends StatelessWidget {
  final String name;
  final IconData icon;
  const _PopularPlace({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 16),
    label: Text(name),
    onPressed: () {
      const places = <String, PlaceResult>{
        'Aeroporto': PlaceResult(
          name: 'Aeroporto Internacional de Luanda',
          address: 'Aeroporto 4 de Fevereiro',
          latitude: -8.858372,
          longitude: 13.231236,
        ),
        'Talatona': PlaceResult(
          name: 'Talatona',
          address: 'Talatona, Luanda Sul',
          latitude: -8.913247,
          longitude: 13.186745,
        ),
        'Miramar': PlaceResult(
          name: 'Miramar',
          address: 'Miramar, Luanda',
          latitude: -8.808912,
          longitude: 13.232456,
        ),
      };
      final place = places[name]!;
      context.read<TripStateProvider>().setDestination(place);
      context.read<MapStateProvider>().updateDestination(
        place.latitude,
        place.longitude,
        place.name,
      );
    },
  );
}

class _RideOptionsSheet extends StatelessWidget {
  final TripStateProvider trip;
  final bool isConfirming;
  const _RideOptionsSheet({
    super.key,
    required this.trip,
    required this.isConfirming,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: MockData.vehicles.map(
                (vehicle) => _VehicleCard(
                  vehicle: vehicle,
                  price: trip.fareFor(vehicle),
                  selected: trip.selectedVehicle?.id == vehicle.id || (trip.selectedVehicle == null && vehicle.id == 'baza'),
                  onTap: () => trip.selectVehicle(vehicle),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2B71),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.remove, color: Colors.black, size: 28),
              ),
              Text(
                'KZ ${trip.estimatedFare?.round() ?? 2400}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2B71),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Recommended price: Kz ${trip.estimatedFare?.round() ?? 2400}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.money, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text('Cash', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Automatically accept the\nKz ${trip.estimatedFare?.round() ?? 2400} offer',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              Switch(
                value: true,
                onChanged: (v) {},
                activeThumbColor: const Color(0xFFFF2B71),
                activeTrackColor: const Color(0x55FF2B71),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: trip.requestDriver,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF2B71),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Find a driver',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ride states ─────────────────────────────────────────────────────────────

/// Neutral inline notice used by the destination sheet while the user is
/// picking a point on the map.
class _HintBanner extends StatelessWidget {
  final String text;
  const _HintBanner({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFECFDF3),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF12A05C)),
    ),
    child: Row(
      children: [
        const Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF12A05C)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B7A45),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Vehicle option rendered inside the dark panel of [_RideOptionsSheet].
class _VehicleCard extends StatelessWidget {
  final VehicleCategory vehicle;
  final double? price;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? const Color(0xFF26262A) : const Color(0xFF1D1D1F),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? const Color(0xFFFF2B71) : Colors.white12,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            vehicle.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: Colors.white54,
                          ),
                          Text(
                            '${vehicle.capacity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.vehicleModel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KZ ${price?.round() ?? '—'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${vehicle.etaMinutes} min',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown while the request is broadcast and no driver is assigned yet.
class _SearchingSheet extends StatelessWidget {
  final VoidCallback onCancel;

  const _SearchingSheet({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFFFF2B71),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'A procurar motorista…',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Estamos a contactar os motores disponíveis na sua zona.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Cancelar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Driver identity plus live distance/ETA, shared by the found, arriving and
/// arrived states.
class _DriverCard extends StatelessWidget {
  final Driver driver;
  final TripState state;
  final int? eta;
  final double? distance;
  final VoidCallback onCancel;

  const _DriverCard({
    required this.driver,
    required this.state,
    required this.eta,
    required this.distance,
    required this.onCancel,
  });

  bool get isArrived => state == TripState.driverArrived;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = driver.photoUrl.isNotEmpty;

    return _SheetFrame(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFFF2B71),
                  child: hasPhoto
                      ? null
                      : Text(
                          driver.name.characters.first,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFC107),
                          ),
                          Text(
                            driver.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${driver.vehicleModel} · ${driver.licensePlate}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.near_me_rounded, size: 18, color: Color(0xFFFF2B71)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isArrived
                          ? 'O motorista chegou'
                          : distance == null
                          ? 'A calcular distância…'
                          : '${distance!.toStringAsFixed(1)} km de distância',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!isArrived && eta != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2B71),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$eta min',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Cancelar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Active trip: destination, running fare and the action to end the ride.
class _TripInProgress extends StatelessWidget {
  final Driver driver;
  final String destination;
  final double? fare;
  final VoidCallback onComplete;

  const _TripInProgress({
    required this.driver,
    required this.destination,
    required this.fare,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viagem em curso',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.trip_origin, size: 12, color: Color(0xFFFF2B71)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    driver.vehicleModel,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_rounded, size: 18, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.isEmpty ? 'Destino' : destination,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total estimado',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  'KZ ${fare?.round() ?? '—'}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: onComplete,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2B71),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Terminar viagem',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Terminal state after the ride is finished.
class _TripCompleted extends StatelessWidget {
  final VoidCallback onNewTrip;

  const _TripCompleted({required this.onNewTrip});

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF12A05C)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 46, color: Color(0xFF12A05C)),
            const SizedBox(height: 14),
            const Text(
              'Viagem concluída',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101820),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'O pagamento é combinado com o motorista.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onNewTrip,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2B71),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Pedir nova viagem',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Terminal state after the request was cancelled.
class _CancelledSheet extends StatelessWidget {
  final VoidCallback onNewTrip;

  const _CancelledSheet({required this.onNewTrip});

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_rounded, size: 46, color: Color(0xFF667085)),
            const SizedBox(height: 14),
            const Text(
              'Pedido cancelado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101820),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nenhum valor foi cobrado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onNewTrip,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF101820),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Pedir nova viagem',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
