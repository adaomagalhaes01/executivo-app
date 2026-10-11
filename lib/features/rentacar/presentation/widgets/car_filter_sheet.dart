import 'package:flutter/material.dart';

import '../../../../core/models/car_attributes.dart';
import '../../../../core/models/car_search_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_sheet.dart';

/// Filter options the sheet needs to build its sections.
///
/// Passed in by the search provider so the sheet never touches a repository
/// itself and can be reused with any catalogue.
class CarFilterOptions {
  const CarFilterOptions({
    required this.brands,
    required this.areas,
    required this.features,
    required this.seats,
    required this.transmissions,
    required this.fuels,
    required this.minPrice,
    required this.maxPrice,
  });

  const CarFilterOptions.empty()
      : brands = const [],
        areas = const [],
        features = const [],
        seats = const [],
        transmissions = const [],
        fuels = const [],
        minPrice = 0,
        maxPrice = 0;

  final List<String> brands;
  final List<String> areas;
  final List<String> features;
  final List<int> seats;
  final List<TransmissionType> transmissions;
  final List<FuelType> fuels;
  final double minPrice;
  final double maxPrice;
}

/// Bottom sheet with every filter group the module supports.
///
/// Edits a local copy and returns it through [onApply]; cancelling discards
/// everything, so the results on screen never change mid-edit.
class CarFilterSheet extends StatefulWidget {
  const CarFilterSheet({
    super.key,
    required this.initial,
    required this.options,
    this.modelsFor,
  });

  final CarSearchFilter initial;
  final CarFilterOptions options;

  /// Models available for a brand. Optional: when the caller has no catalogue
  /// (e.g. a test), the model section is simply hidden.
  final List<String> Function(String brand)? modelsFor;

  /// Opens the sheet and resolves to the new filter, or `null` if dismissed.
  static Future<CarSearchFilter?> show(
    BuildContext context, {
    required CarSearchFilter initial,
    required CarFilterOptions options,
    List<String> Function(String brand)? modelsFor,
  }) {
    return showModalBottomSheet<CarSearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CarFilterSheet(
        initial: initial,
        options: options,
        modelsFor: modelsFor,
      ),
    );
  }

  @override
  State<CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<CarFilterSheet> {
  late CarSearchFilter _draft;
  RangeValues _priceRange = const RangeValues(0, 1);

  RangeValues _initialRange() {
    if (widget.options.maxPrice <= widget.options.minPrice) {
      return const RangeValues(0, 1);
    }
    final step = widget.options.maxPrice - widget.options.minPrice;
    final min = widget.initial.price.min ?? widget.options.minPrice;
    final max = widget.initial.price.max ?? widget.options.maxPrice;
    return RangeValues(
      ((min - widget.options.minPrice) / step).clamp(0.0, 1.0),
      ((max - widget.options.minPrice) / step).clamp(0.0, 1.0),
    );
  }

  PriceRange get _price {
    final step = widget.options.maxPrice - widget.options.minPrice;
    if (step <= 0) return PriceRange.unbounded;
    final min = widget.options.minPrice + _priceRange.start * step;
    final max = widget.options.minPrice + _priceRange.end * step;
    return PriceRange(
      min: min.roundToDouble(),
      max: max.roundToDouble(),
    );
  }

  bool get _priceTouched =>
      widget.initial.price.isUnbounded
          ? (_priceRange.start > 0.01 || _priceRange.end < 0.99)
          : _price != widget.initial.price;

  void _toggleBrand(String brand) {
    setState(() {
      final brands = {..._draft.brands};
      if (!brands.remove(brand)) brands.add(brand);
      _draft = _draft.copyWith(brands: brands, models: const {});
    });
  }

  void _toggleModel(String model) {
    setState(() {
      final models = {..._draft.models};
      if (!models.remove(model)) models.add(model);
      _draft = _draft.copyWith(models: models);
    });
  }

  void _toggleArea(String area) {
    setState(() {
      final areas = {..._draft.neighbourhoods};
      if (!areas.remove(area)) areas.add(area);
      _draft = _draft.copyWith(neighbourhoods: areas);
    });
  }

  void _toggleFeature(String feature) {
    setState(() {
      final features = {..._draft.features};
      if (!features.remove(feature)) features.add(feature);
      _draft = _draft.copyWith(features: features);
    });
  }

  void _toggleSeat(int seats) {
    setState(() {
      final values = {..._draft.seats};
      if (!values.remove(seats)) values.add(seats);
      _draft = _draft.copyWith(seats: values);
    });
  }

  void _toggleTransmission(TransmissionType type) {
    setState(() {
      final values = {..._draft.transmissions};
      if (!values.remove(type)) values.add(type);
      _draft = _draft.copyWith(transmissions: values);
    });
  }

  void _toggleFuel(FuelType fuel) {
    setState(() {
      final values = {..._draft.fuels};
      if (!values.remove(fuel)) values.add(fuel);
      _draft = _draft.copyWith(fuels: values);
    });
  }

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _priceRange = _initialRange();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final hasRange = options.maxPrice > options.minPrice;

    return ExecutiveSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filtros',
                  style: AppTextStyles.headingSm,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _draft = CarSearchFilter.none;
                }),
                child: const Text('Limpar tudo'),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _draft.onlyAvailable,
                    onChanged: (value) => setState(() {
                      _draft = _draft.copyWith(onlyAvailable: value);
                    }),
                    title: Text(
                      'Apenas disponíveis',
                      style: AppTextStyles.bodyLg,
                    ),
                    subtitle: Text(
                      'Esconde veículos alugados ou com datas bloqueadas',
                      style: AppTextStyles.captionSm,
                    ),
                  ),
                  if (hasRange) ...[
                    const _SectionTitle('Preço por dia'),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1,
                      labels: RangeLabels(
                        RentFormatters.kwanzaCompact(_price.min ?? 0),
                        RentFormatters.kwanzaCompact(_price.max ?? 0),
                      ),
                      onChanged: (values) =>
                          setState(() => _priceRange = values),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          RentFormatters.kwanza(
                            _priceRange.start == 0
                                ? 0
                                : _price.min ?? options.minPrice,
                          ),
                          style: AppTextStyles.captionSm,
                        ),
                        Text(
                          _priceTouched
                              ? 'Personalizado'
                              : 'Qualquer preço',
                          style: AppTextStyles.captionSm,
                        ),
                        Text(
                          RentFormatters.kwanza(
                            _priceRange.end == 1
                                ? options.maxPrice
                                : _price.max ?? options.maxPrice,
                          ),
                          style: AppTextStyles.captionSm,
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                  ],
                  if (options.brands.isNotEmpty) ...[
                    const _SectionTitle('Marca'),
                    _WrapOptions(
                      children: [
                        for (final brand in options.brands)
                          _OptionChip(
                            label: brand,
                            selected: _draft.brands.contains(brand),
                            onTap: () => _toggleBrand(brand),
                          ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                  ],
                  if (_draft.brands.isNotEmpty)
                    for (final brand in _draft.brands) ...[
                      _SectionTitle('Modelos · $brand'),
                      _WrapOptions(
                        children: [
                          for (final model in _modelsFor(brand))
                            _OptionChip(
                              label: model,
                              selected: _draft.models.contains(model),
                              onTap: () => _toggleModel(model),
                            ),
                        ],
                      ),
                      const Divider(height: AppSpacing.xl),
                    ],
                  if (options.areas.isNotEmpty) ...[
                    const _SectionTitle('Local de entrega'),
                    _WrapOptions(
                      children: [
                        for (final area in options.areas)
                          _OptionChip(
                            label: area,
                            selected:
                                _draft.neighbourhoods.contains(area),
                            onTap: () => _toggleArea(area),
                          ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                  ],
                  if (options.seats.isNotEmpty) ...[
                    const _SectionTitle('Lugares'),
                    _WrapOptions(
                      children: [
                        for (final seats in options.seats)
                          _OptionChip(
                            label: '$seats lugares',
                            selected: _draft.seats.contains(seats),
                            onTap: () => _toggleSeat(seats),
                          ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                  ],
                  if (options.transmissions.isNotEmpty) ...[
                    const _SectionTitle('Caixa'),
                    _WrapOptions(
                      children: [
                        for (final type in options.transmissions)
                          _OptionChip(
                            label: type.label,
                            selected: _draft.transmissions.contains(type),
                            onTap: () => _toggleTransmission(type),
                          ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                  ],
                  if (options.fuels.isNotEmpty) ...[
                    const _SectionTitle('Combustível'),
                    _WrapOptions(
                      children: [
                        for (final fuel in options.fuels)
                          _OptionChip(
                            label: fuel.label,
                            selected: _draft.fuels.contains(fuel),
                            onTap: () => _toggleFuel(fuel),
                          ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xl),
                  ],
                  if (options.features.isNotEmpty) ...[
                    const _SectionTitle('Características'),
                    _WrapOptions(
                      children: [
                        for (final feature in options.features)
                          _OptionChip(
                            label: feature,
                            selected: _draft.features.contains(feature),
                            onTap: () => _toggleFeature(feature),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _draft.copyWith(price: _priceTouched ? _price : PriceRange.unbounded),
                    );
                  },
                  child: Text(
                    'Ver resultados (${_draft.activeCount + (_priceTouched ? 1 : 0)})',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _modelsFor(String brand) {
    if (widget.modelsFor == null) return const [];
    return widget.modelsFor!(brand);
  }
}

/// Section heading inside the sheet.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: RentCarColors.primary,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

/// Wrapping row of chips that flows onto more lines when needed.
class _WrapOptions extends StatelessWidget {
  const _WrapOptions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: children);
  }
}

/// Selectable filter pill.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? RentCarColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? RentCarColors.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: selected ? Colors.white : null,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}