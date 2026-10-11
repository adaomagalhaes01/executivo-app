import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/map_style_dark.dart';
import 'providers/trip_state_provider.dart';
import 'providers/map_state_provider.dart';
import 'widgets/trip_bottom_sheet.dart';
import '../../../core/models/trip_state.dart';
import '../../history/presentation/history_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tripProvider = context.read<TripStateProvider>();
      final mapProvider = context.read<MapStateProvider>();
      await tripProvider.initLocation();
      final loc = tripProvider.passengerLocation;
      if (loc != null && mounted) {
        mapProvider.updatePassengerLocation(loc);
        mapProvider.moveCameraToPassenger();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const _AppDrawer(),
      body: Stack(
        children: [
          const _MapLayer(),
          const _TopControls(),
          const _ErrorBanner(),

          const Align(
            alignment: Alignment.bottomCenter,
            child: TripBottomSheet(),
          ),
        ],
      ),
    );
  }
}

// ─── Map Layer ────────────────────────────────────────────────────────────────
class _MapLayer extends StatefulWidget {
  const _MapLayer();

  @override
  State<_MapLayer> createState() => _MapLayerState();
}

class _MapLayerState extends State<_MapLayer> {
  LatLng? _lastPassengerLocation;
  DateTime? _lastDriverUpdate;
  TripState? _lastTripState;

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapStateProvider>();
    final tripProvider = context.watch<TripStateProvider>();

    final passenger = tripProvider.passengerLocation;
    if (passenger != null && passenger != _lastPassengerLocation) {
      _lastPassengerLocation = passenger;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MapStateProvider>().updatePassengerLocation(passenger);
        }
      });
    }

    final driverLoc = tripProvider.driverLocation;
    if (driverLoc != null && driverLoc.timestamp != _lastDriverUpdate) {
      _lastDriverUpdate = driverLoc.timestamp;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final map = context.read<MapStateProvider>();
        map.updateDriverLocation(driverLoc);
        if (tripProvider.tripState == TripState.driverArriving ||
            tripProvider.tripState == TripState.driverArrived ||
            tripProvider.tripState == TripState.tripStarted) {
          final target = tripProvider.tripState == TripState.tripStarted
              ? tripProvider.destination
              : null;
          map.addDriverRoute(
            LatLng(driverLoc.latitude, driverLoc.longitude),
            destination: target == null
                ? null
                : LatLng(target.latitude, target.longitude),
          );
        }
      });
    }

    if (_lastTripState != tripProvider.tripState &&
        (tripProvider.tripState == TripState.idle ||
            tripProvider.tripState == TripState.cancelled ||
            tripProvider.tripState == TripState.tripCompleted)) {
      _lastTripState = tripProvider.tripState;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<MapStateProvider>().clearDriver();
      });
    }
    _lastTripState = tripProvider.tripState;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(-8.839988, 13.289437), // Luanda, Angola
        zoom: 13,
      ),
      style: isDark ? MapStyle.dark : null,
      myLocationEnabled: tripProvider.passengerLocation != null,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: mapProvider.markers,
      polylines: mapProvider.polylines,
      onTap: (location) {
        if (tripProvider.isPickingDestination) {
          tripProvider.selectDestinationOnMap(location);
          context.read<MapStateProvider>().updateDestination(
            location.latitude,
            location.longitude,
            'Local seleccionado no mapa',
          );
        }
      },
      onMapCreated: (controller) {
        context.read<MapStateProvider>().setMapController(controller);
        final loc = context.read<TripStateProvider>().passengerLocation;
        if (loc != null) {
          context.read<MapStateProvider>().updatePassengerLocation(loc);
        }
      },
    );
  }
}

// ─── Top Controls ─────────────────────────────────────────────────────────────
class _TopControls extends StatelessWidget {
  const _TopControls();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Builder(
              builder: (ctx) => _MapButton(
                icon: Icons.menu,
                onTap: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EXECUTIVO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: Color(0xFF101820),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.circle, size: 7, color: Color(0xFFE8000D)),
                ],
              ),
            ),
            const Spacer(),
            _MapButton(
              icon: Icons.my_location,
              onTap: () async {
                final trips = context.read<TripStateProvider>();
                if (trips.passengerLocation == null) {
                  await trips.initLocation();
                }
                final location = trips.passengerLocation;
                if (location != null && context.mounted) {
                  context.read<MapStateProvider>().moveCamera(location);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF101820)),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    final error = context.select<TripStateProvider, String>(
      (p) => p.errorMessage,
    );
    if (error.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD600)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF79009),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF663C00),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final trips = context.read<TripStateProvider>();
                  final map = context.read<MapStateProvider>();
                  await trips.initLocation();
                  final position = trips.passengerLocation;
                  if (position != null) {
                    map.updatePassengerLocation(position);
                    map.moveCameraToPassenger();
                  }
                },
                child: const Text(
                  'Tentar',
                  style: TextStyle(
                    color: Color(0xFF663C00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App Drawer ───────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF101010),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFFFF2B71), size: 32),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 48),
              _MenuText(label: 'PROFILE', onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }),
              const SizedBox(height: 24),
              _MenuText(label: 'MY ORDERS', onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
              }),
              const SizedBox(height: 24),
              _MenuText(label: 'PROMOTIONS', onTap: () {}),
              const SizedBox(height: 24),
              _MenuText(label: 'HELP', onTap: () {}),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  minimumSize: Size.zero,
                  elevation: 0,
                ),
                child: const Text(
                  'Switch to driver app',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Divider(color: Color(0xFF2C2C2E)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable light mode', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Switch(
                    value: false,
                    onChanged: (v) {},
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF2C2C2E),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: const Color(0xFF2C2C2E),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuText({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontFamily: 'Montserrat', // or similar if available
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
