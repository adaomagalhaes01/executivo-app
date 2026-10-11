import 'package:flutter/material.dart';

import '../../../../core/data/mock_rentacar_data.dart';
import '../../../../core/models/rental_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/executive_sheet.dart';

/// Bottom sheet listing every pickup/delivery point, grouped by city.
///
/// Options come from the dataset instead of a places API so the flow works
/// offline; swapping in an autocomplete later only touches this widget.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({
    super.key,
    this.selected,
    this.locations,
  });

  final RentalLocation? selected;

  /// Defaults to the mocked pickup points.
  final List<RentalLocation>? locations;

  /// Opens the sheet, resolving to the chosen location or `null`.
  static Future<RentalLocation?> show(
    BuildContext context, {
    RentalLocation? selected,
    List<RentalLocation>? locations,
  }) {
    return showModalBottomSheet<RentalLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        selected: selected,
        locations: locations,
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  String _query = '';

  List<RentalLocation> get _all =>
      widget.locations ?? MockRentCarData.pickupPoints;

  List<RentalLocation> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _all;
    return _all.where((location) {
      return location.label.toLowerCase().contains(query) ||
          location.city.toLowerCase().contains(query) ||
          location.address.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    final byCity = <String, List<RentalLocation>>{};
    for (final location in results) {
      final key = location.city.isEmpty ? 'Outras áreas' : location.city;
      byCity.putIfAbsent(key, () => []).add(location);
    }

    return ExecutiveSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Onde precisa do carro?', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'O veículo pode ser entregue no local escolhido.',
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Bairro, cidade ou morada',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Nenhum local corresponde à pesquisa.',
                  style: AppTextStyles.bodyMd,
                ),
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in byCity.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.md,
                          bottom: AppSpacing.xs,
                        ),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: AppTextStyles.labelSm.copyWith(
                            color: RentCarColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      for (final location in entry.value)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(
                            _iconFor(location.kind),
                            color: RentCarColors.primary,
                          ),
                          title: Text(location.label),
                          subtitle: Text(location.address),
                          trailing: widget.selected?.sameAs(location) ?? false
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: RentCarColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(location),
                        ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconFor(LocationKind kind) {
    switch (kind) {
      case LocationKind.airport:
        return Icons.flight_rounded;
      case LocationKind.mall:
        return Icons.shopping_bag_rounded;
      case LocationKind.hotel:
        return Icons.hotel_rounded;
      case LocationKind.office:
        return Icons.apartment_rounded;
      case LocationKind.neighbourhood:
      case LocationKind.other:
        return Icons.place_rounded;
    }
  }
}