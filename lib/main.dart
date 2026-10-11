import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/data/mock_rentacar_data.dart';
import 'core/repositories/mock_availability_repository.dart';
import 'core/repositories/mock_car_repository.dart';
import 'core/repositories/mock_rental_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/providers/map_state_provider.dart';
import 'features/home/presentation/providers/trip_state_provider.dart';
import 'features/rentacar/presentation/providers/car_search_provider.dart';
import 'features/rentacar/presentation/providers/rentacar_owner_provider.dart';
import 'features/rentacar/presentation/providers/rentacar_rental_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  runApp(const ExecutivoApp());
}

class ExecutivoApp extends StatefulWidget {
  const ExecutivoApp({super.key});

  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  @override
  State<ExecutivoApp> createState() => _ExecutivoAppState();
}

class _ExecutivoAppState extends State<ExecutivoApp> {
  /// One catalogue instance shared by every Rent a Car screen, so a vehicle
  /// published by the owner is immediately visible in the renter flow.
  ///
  /// Swap these three lines for the Supabase-backed implementations once the
  /// backend exists — no screen or provider code has to change.
  final CarRepositoryBundle _rentCarRepositories = CarRepositoryBundle();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripStateProvider()),
        ChangeNotifierProvider(create: (_) => MapStateProvider()),

        // ─── Rent a Car ─────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => CarSearchProvider(
            repository: _rentCarRepositories.cars,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RentCarOwnerProvider(
            carRepository: _rentCarRepositories.cars,
            availabilityRepository: _rentCarRepositories.availability,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              RentCarRentalProvider(rentalRepository: _rentCarRepositories.rentals),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ExecutivoApp.themeNotifier,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: 'EXECUTIVO',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

/// Groups the Rent a Car repositories so they are created once and share the
/// same seeded catalogue.
class CarRepositoryBundle {
  CarRepositoryBundle()
      : cars = MockCarRepository(seed: MockRentCarData.cars),
        rentals = MockRentalRepository();

  final MockCarRepository cars;
  final MockRentalRepository rentals;

  late final MockAvailabilityRepository availability =
      MockAvailabilityRepository(seed: cars.snapshot);
}