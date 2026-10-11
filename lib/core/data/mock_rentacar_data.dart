import '../models/car.dart';
import '../models/car_attributes.dart';
import '../models/car_availability.dart';
import '../models/car_rules.dart';
import '../models/rental_location.dart';
import '../models/rental_owner.dart';
import '../models/rental_pricing.dart';
import '../models/vehicle_image.dart';

/// Seed data for the Rent a Car module.
///
/// Every vehicle here is bundled with real photographs so the module can be
/// demonstrated end to end without a backend. When the API goes live the same
/// records are returned by `CarRepository` instead — nothing in the UI changes.
abstract final class MockRentCarData {
  // ─── Photo sets ────────────────────────────────────────────────────────────
  // Each slug maps to <slug>_cover / <slug>_angle / <slug>_interior.
  static const String _corolla = 'assets/images/rentacar/corolla';
  static const String _landcruiser = 'assets/images/rentacar/landcruiser';
  static const String _tucson = 'assets/images/rentacar/tucson';
  static const String _hilux = 'assets/images/rentacar/hilux';
  static const String _cclass = 'assets/images/rentacar/cclass';
  static const String _golf = 'assets/images/rentacar/golf';
  static const String _hiace = 'assets/images/rentacar/hiace';
  static const String _duster = 'assets/images/rentacar/duster';

  static List<VehicleImage> photos(String slug) => [
        VehicleImage(
          id: '${slug}_cover',
          source: VehicleImageSource.asset,
          path: '${slug}_cover.jpg',
          label: 'Frente',
          isCover: true,
        ),
        VehicleImage(
          id: '${slug}_angle',
          source: VehicleImageSource.asset,
          path: '${slug}_angle.jpg',
          label: 'Traseira',
        ),
        VehicleImage(
          id: '${slug}_interior',
          source: VehicleImageSource.asset,
          path: '${slug}_interior.jpg',
          label: 'Interior',
        ),
      ];

  // ─── Owners ────────────────────────────────────────────────────────────────

  static const RentalOwner angola = RentalOwner(
    id: 'owner_angola',
    name: 'António Cardoso',
    rating: 4.9,
    totalRentals: 84,
    isVerified: true,
    responseRate: 98,
    typicalResponseMinutes: 12,
    memberSince: null,
  );

  static const RentalOwner luana = RentalOwner(
    id: 'owner_luana',
    name: 'Luana Fernandes',
    rating: 4.8,
    totalRentals: 51,
    isVerified: true,
    responseRate: 95,
    typicalResponseMinutes: 25,
  );

  static const RentalOwner diego = RentalOwner(
    id: 'owner_diego',
    name: 'Diego Manuel',
    rating: 4.7,
    totalRentals: 33,
    responseRate: 90,
    typicalResponseMinutes: 40,
  );

  static const RentalOwner currentOwner = RentalOwner(
    id: 'owner_current',
    name: 'Adão Magalhães',
    rating: 5.0,
    totalRentals: 12,
    isVerified: true,
    responseRate: 100,
    typicalResponseMinutes: 8,
  );

  // ─── Pickup points around Luanda ───────────────────────────────────────────

  static const RentalLocation talatona = RentalLocation(
    latitude: -8.9194,
    longitude: 13.1845,
    address: 'Av. 4 de Fevereiro, Talatona',
    neighbourhood: 'Talatona',
    city: 'Luanda',
  );

  static const RentalLocation miramar = RentalLocation(
    latitude: -8.8184,
    longitude: 13.2334,
    address: 'Av. 4 de Fevereiro, Miramar',
    neighbourhood: 'Miramar',
    city: 'Luanda',
  );

  static const RentalLocation centro = RentalLocation(
    latitude: -8.8390,
    longitude: 13.2894,
    address: 'Av. Deolinda Rodrigues, Ingombota',
    neighbourhood: 'Ingombota',
    city: 'Luanda',
  );

  static const RentalLocation benfica = RentalLocation(
    latitude: -8.8667,
    longitude: 13.2333,
    address: 'Estrada da Samba, Benfica',
    neighbourhood: 'Benfica',
    city: 'Luanda',
  );

  static const RentalLocation viana = RentalLocation(
    latitude: -8.9261,
    longitude: 13.3567,
    address: 'Estrada de Viana, Viana',
    neighbourhood: 'Viana',
    city: 'Luanda',
  );

  // ─── Neighbourhood suggestions for the search field ────────────────────────

  static const List<RentalLocation> pickupPoints = [
    centro,
    talatona,
    miramar,
    benfica,
    viana,
  ];

  static const List<String> neighborhoods = [
    'Ingombota',
    'Talatona',
    'Miramar',
    'Benfica',
    'Viana',
  ];

  static const List<String> brands = [
    'Toyota',
    'Hyundai',
    'Mercedes-Benz',
    'Volkswagen',
    'Renault',
  ];

  static const Map<String, List<String>> modelsByBrand = {
    'Toyota': ['Corolla', 'Land Cruiser Prado', 'Hilux', 'Hiace'],
    'Hyundai': ['Tucson'],
    'Mercedes-Benz': ['Classe C'],
    'Volkswagen': ['Golf'],
    'Renault': ['Duster'],
  };

  // ─── Feature catalogue used by the filter sheet ────────────────────────────

  static const List<String> features = [
    'Ar condicionado',
    'Bluetooth',
    'Câmera de ré',
    'GPS',
    'Sensor de estacionamento',
    'Vidros eléctricos',
    'Travas elétricas',
    'Faróis LED',
  ];

  // ─── Catalogue ─────────────────────────────────────────────────────────────

  static final List<Car> cars = [
    Car(
      id: 'car_corolla',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2024,
      plate: 'LD-42-18-KZ',
      color: 'Prata',
      mileageKm: 18400,
      transmission: TransmissionType.automatic,
      fuel: FuelType.gasoline,
      seats: 5,
      pricing: const RentalPricing(
        pricePerDay: 25000,
        pricePerWeek: 150000,
        pricePerMonth: 520000,
        serviceFee: 5000,
        deposit: 80000,
      ),
      location: talatona,
      images: photos(_corolla),
      owner: angola,
      description:
          'Sedã compacto, confortável e económico para deslocações diárias '
          'e viagens dentro da cidade. Interior limpo e cuidado, com ar '
          'condicionado e rádio com Bluetooth.',
      features: const [
        'Ar condicionado',
        'Bluetooth',
        'Câmera de ré',
        'Vidros eléctricos',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 200,
        extraKilometrePrice: 450,
        deposit: 80000,
        minimumAge: 21,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 24h antes',
      ),
      availability: CarAvailability(
        blockedPeriods: [
          BlockedPeriod(
            start: DateTime.now().add(const Duration(days: 12)),
            end: DateTime.now().add(const Duration(days: 16)),
            reason: 'Viagem pessoal',
          ),
        ],
      ),
      rating: 4.8,
      reviewsCount: 42,
      createdAt: DateTime(2026, 4, 12),
    ),
    Car(
      id: 'car_landcruiser',
      brand: 'Toyota',
      model: 'Land Cruiser Prado',
      year: 2023,
      plate: 'LD-07-93-AX',
      color: 'Branco',
      mileageKm: 42700,
      transmission: TransmissionType.automatic,
      fuel: FuelType.diesel,
      seats: 7,
      pricing: const RentalPricing(
        pricePerDay: 65000,
        pricePerWeek: 400000,
        serviceFee: 8000,
        deposit: 200000,
      ),
      location: miramar,
      images: photos(_landcruiser),
      owner: luana,
      description:
          'SUV de sete lugares preparado para estradas de terra e viagens '
          'longas. Tração elevada, espaço generoso para bagagem e conforto '
          'em todas as viagens.',
      features: const [
        'Ar condicionado',
        'GPS',
        'Sensor de estacionamento',
        'Faróis LED',
        'Travas elétricas',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 300,
        extraKilometrePrice: 600,
        deposit: 200000,
        minimumAge: 25,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 48h antes',
      ),
      rating: 4.9,
      reviewsCount: 27,
      createdAt: DateTime(2026, 2, 3),
    ),
    Car(
      id: 'car_tucson',
      brand: 'Hyundai',
      model: 'Tucson',
      year: 2023,
      plate: 'LD-55-31-QT',
      color: 'Grafite',
      mileageKm: 29600,
      transmission: TransmissionType.automatic,
      fuel: FuelType.diesel,
      seats: 5,
      pricing: const RentalPricing(
        pricePerDay: 32000,
        pricePerWeek: 195000,
        serviceFee: 5000,
        deposit: 100000,
      ),
      location: benfica,
      images: photos(_tucson),
      owner: angola,
      description:
          'SUV urbano com boa posição de condução e consumo equilibrado. '
          'Ideal para quem quer a altura de um SUV sem o consumo de um.',
      features: const [
        'Ar condicionado',
        'Bluetooth',
        'Câmera de ré',
        'Sensor de estacionamento',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 250,
        extraKilometrePrice: 500,
        deposit: 100000,
        minimumAge: 23,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 24h antes',
      ),
      rating: 4.7,
      reviewsCount: 19,
      createdAt: DateTime(2026, 5, 20),
    ),
    Car(
      id: 'car_hilux',
      brand: 'Toyota',
      model: 'Hilux',
      year: 2022,
      plate: 'LD-19-77-JJ',
      color: 'Cinzento',
      mileageKm: 61200,
      transmission: TransmissionType.manual,
      fuel: FuelType.diesel,
      seats: 5,
      pricing: const RentalPricing(
        pricePerDay: 38000,
        pricePerWeek: 230000,
        serviceFee: 6000,
        deposit: 150000,
      ),
      location: viana,
      images: photos(_hilux),
      owner: diego,
      description:
          'Pick-up de caixa dupla para obras, transporte de material ou '
          'viagens com equipamento. Caixa de carga ampla e suspensão '
          'reforçada.',
      features: const [
        'Ar condicionado',
        'Vidros eléctricos',
        'Travas elétricas',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 250,
        extraKilometrePrice: 550,
        deposit: 150000,
        minimumAge: 25,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 24h antes',
      ),
      rating: 4.6,
      reviewsCount: 31,
      createdAt: DateTime(2026, 1, 18),
    ),
    Car(
      id: 'car_cclass',
      brand: 'Mercedes-Benz',
      model: 'Classe C',
      year: 2024,
      plate: 'LD-88-14-MN',
      color: 'Preto',
      mileageKm: 12300,
      transmission: TransmissionType.automatic,
      fuel: FuelType.gasoline,
      seats: 5,
      pricing: const RentalPricing(
        pricePerDay: 78000,
        pricePerWeek: 470000,
        pricePerMonth: 1600000,
        serviceFee: 10000,
        deposit: 250000,
      ),
      location: centro,
      images: photos(_cclass),
      owner: luana,
      description:
          'Sedã executivo com acabamento premium, bancos em pele e '
          'silenciosa de condução. A escolha certa para eventos e viagens '
          'de negócios.',
      features: const [
        'Ar condicionado',
        'GPS',
        'Bluetooth',
        'Faróis LED',
        'Sensor de estacionamento',
        'Travas elétricas',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 250,
        extraKilometrePrice: 900,
        deposit: 250000,
        minimumAge: 28,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 48h antes',
      ),
      rating: 5.0,
      reviewsCount: 14,
      createdAt: DateTime(2026, 6, 2),
    ),
    Car(
      id: 'car_golf',
      brand: 'Volkswagen',
      model: 'Golf',
      year: 2021,
      plate: 'LD-63-52-UP',
      color: 'Azul',
      mileageKm: 74800,
      transmission: TransmissionType.manual,
      fuel: FuelType.gasoline,
      seats: 5,
      pricing: const RentalPricing(
        pricePerDay: 21000,
        pricePerWeek: 125000,
        serviceFee: 4000,
        deposit: 70000,
      ),
      location: talatona,
      images: photos(_golf),
      owner: diego,
      description:
          'Compacto manual, económico e ágil no trânsito. Uma opção '
          'acessível para quem só precisa de um carro fiável.',
      features: const [
        'Ar condicionado',
        'Bluetooth',
        'Vidros eléctricos',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 200,
        extraKilometrePrice: 400,
        deposit: 70000,
        minimumAge: 21,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 24h antes',
      ),
      rating: 4.5,
      reviewsCount: 38,
      createdAt: DateTime(2026, 3, 9),
    ),
    Car(
      id: 'car_hiace',
      brand: 'Toyota',
      model: 'Hiace',
      year: 2022,
      plate: 'LD-31-05-RW',
      color: 'Branco',
      mileageKm: 88600,
      transmission: TransmissionType.manual,
      fuel: FuelType.diesel,
      seats: 9,
      pricing: const RentalPricing(
        pricePerDay: 55000,
        pricePerWeek: 330000,
        serviceFee: 7000,
        deposit: 150000,
      ),
      location: centro,
      images: photos(_hiace),
      owner: angola,
      description:
          'Carrinha de nove lugares para grupos, excursões e deslocações '
          'corporativas. Ar condicionado em toda a cabine.',
      features: const [
        'Ar condicionado',
        'GPS',
        'Vidros eléctricos',
      ],
      rules: const CarRules(
        dailyKilometreLimit: 250,
        extraKilometrePrice: 600,
        deposit: 150000,
        minimumAge: 25,
        requiredDocuments: ['Carta de Condução', 'BI ou Passaporte'],
        fuelPolicy: 'Depósito cheio para depósito cheio',
        cancellationPolicy: 'Cancelamento gratuito até 48h antes',
      ),
      rating: 4.6,
      reviewsCount: 22,
      createdAt: DateTime(2026, 4, 27),
    ),
    Car(
      id: 'car_duster',
      brand: 'Renault',
      model: 'Duster',
      year: 2023,
      plate: 'LD-74-66-HC',
      color: 'Bege',
      mileageKm: 34900,
      transmission: TransmissionType.manual,
      fuel: FuelType.gasoline,
      seats: 5,
      pricing: const RentalPricing(
        pricePerDay: 27000,
        pricePerWeek: 160000,
        serviceFee: 4500,
        deposit: 80000,
      ),
      location: benfica,
      images: photos(_duster),
      owner: diego,
      description:
          'SUV compacto com boa altura ao solo e espaço para a família. '
          'Robusto o suficiente para estradas secundárias.',
      features: const [
        'Ar condicionado',
        'Bluetooth',
        'Vidros elétricas',
        'Travas elétricas',
      ],
      rating: 4.4,
      reviewsCount: 16,
      createdAt: DateTime(2026, 7, 15),
    ),
  ];

  /// Vehicles published by the signed-in user, used by "Meus carros".
  static List<Car> ownedCars(List<Car> catalogue) => catalogue
      .where((car) => car.owner.id == currentOwner.id)
      .toList(growable: false);

  /// Price bounds of the catalogue — seeds the filter sheet slider.
  static double get minPrice =>
      cars.map((c) => c.pricing.pricePerDay).reduce((a, b) => a < b ? a : b);

  static double get maxPrice =>
      cars.map((c) => c.pricing.pricePerDay).reduce((a, b) => a > b ? a : b);
}