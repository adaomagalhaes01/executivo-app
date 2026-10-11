/// Transmission of a rental vehicle.
enum TransmissionType { manual, automatic }

/// Fuel type of a rental vehicle.
enum FuelType { gasoline, diesel, hybrid, electric }

/// Publication state of a vehicle owned by the current user.
enum CarStatus { active, paused, rented, pending, inactive }

/// Portuguese labels for [TransmissionType].
extension TransmissionTypeX on TransmissionType {
  String get label => switch (this) {
        TransmissionType.manual => 'Manual',
        TransmissionType.automatic => 'Automático',
      };
}

/// Portuguese labels for [FuelType].
extension FuelTypeX on FuelType {
  String get label => switch (this) {
        FuelType.gasoline => 'Gasolina',
        FuelType.diesel => 'Gasóleo',
        FuelType.hybrid => 'Híbrido',
        FuelType.electric => 'Elétrico',
      };
}

/// Portuguese labels for [CarStatus].
extension CarStatusX on CarStatus {
  String get label => switch (this) {
        CarStatus.active => 'Ativo',
        CarStatus.paused => 'Pausado',
        CarStatus.rented => 'Alugado',
        CarStatus.pending => 'Pendente',
        CarStatus.inactive => 'Inativo',
      };
}