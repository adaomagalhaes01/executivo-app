import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../providers/car_search_provider.dart';
import '../widgets/car_filter_sheet.dart';
import '../widgets/location_picker_sheet.dart';
import 'car_results_screen.dart';

/// Search form: where, when, and whether the vehicle is delivered.
///
/// Everything is optional — an empty search shows the whole catalogue, which is
/// what a first-time user sees after tapping "Alugar um carro".
class CarSearchScreen extends StatefulWidget {
  const CarSearchScreen({super.key});

  @override
  State<CarSearchScreen> createState() => _CarSearchScreenState();
}

class _CarSearchScreenState extends State<CarSearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarSearchProvider>().loadCatalogue();
    });
  }

  Future<void> _pickLocation() async {
    final provider = context.read<CarSearchProvider>();
    final location = await LocationPickerSheet.show(
      context,
      selected: provider.criteria.location,
    );
    if (location == null || !mounted) return;
    provider.setLocation(location);
  }

  Future<void> _pickDates() async {
    final provider = context.read<CarSearchProvider>();
    final criteria = provider.criteria;
    final now = DateTime.now();
    final pickup = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: criteria.hasDates
          ? DateTimeRange(
              start: criteria.pickupDate!,
              end: criteria.returnDate!,
            )
          : null,
      helpText: 'Selecionar as datas da reserva',
      saveText: 'Confirmar',
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (pickup == null || !mounted) return;
    provider.setDates(pickup: pickup.start, returnDate: pickup.end);
  }

  Future<void> _openFilters() async {
    final provider = context.read<CarSearchProvider>();
    if (provider.catalogue.isEmpty) await provider.loadCatalogue();
    if (!mounted) return;

    final result = await CarFilterSheet.show(
      context,
      initial: provider.filter,
      options: CarFilterOptions(
        brands: provider.availableBrands,
        areas: provider.availableAreas,
        features: provider.availableFeatures,
        seats: provider.availableSeatCounts,
        transmissions: provider.availableTransmissions,
        fuels: provider.availableFuels,
        minPrice: provider.minPrice,
        maxPrice: provider.maxPrice,
      ),
      modelsFor: provider.availableModels,
    );
    if (result == null || !mounted) return;
    await provider.applyFilter(result);
    if (!mounted) return;
    await _goToResults();
  }

  Future<void> _submit() async {
    await context.read<CarSearchProvider>().search();
    if (!mounted) return;
    await _goToResults();
  }

  Future<void> _goToResults() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RentCarTheme.wrap(const CarResultsScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final provider = context.watch<CarSearchProvider>();
    final criteria = provider.criteria;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alugar um carro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  _Field(
                    icon: Icons.place_rounded,
                    label: 'Local de entrega',
                    value: criteria.location?.label,
                    hint: 'Talatona, Miramar, Ingombota…',
                    onTap: _pickLocation,
                    onClear: criteria.location == null
                        ? null
                        : () => provider.setLocation(null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Field(
                    icon: Icons.calendar_month_rounded,
                    label: 'Datas da reserva',
                    value: criteria.hasDates
                        ? RentFormatters.dateRange(
                            criteria.pickupDate!,
                            criteria.returnDate!,
                          )
                        : null,
                    hint: 'Escolha o levantamento e a devolução',
                    onTap: _pickDates,
                    onClear: criteria.hasDates
                        ? () => provider.setDates(clear: true)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DeliveryToggle(
                    value: criteria.withDelivery,
                    onChanged: provider.setDelivery,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FiltersButton(
                    activeCount: provider.filter.activeCount,
                    onTap: _openFilters,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Dicas',
                    style: AppTextStyles.titleMd.copyWith(color: textColor),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Reservas com entrega custam até 15% menos em alguns '
                    'veículos. Confirme o local final com o proprietário '
                    'antes de levantar.',
                    style: AppTextStyles.bodyMd.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            _SearchBar(
              isLoading: provider.isLoading,
              onTap: _submit,
              subtitle: criteria.hasDates
                  ? '${criteria.days} ${criteria.days == 1 ? 'dia' : 'dias'}'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary;
    final borderColor = isDark ? AppColors.darkElevated : AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularInput,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.circularInput,
            border: Border.all(
              color: value == null ? borderColor : RentCarColors.primary,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: RentCarColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTextStyles.labelSm.copyWith(
                        color: mutedColor,
                        letterSpacing: 0.6,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ?? hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: value == null ? mutedColor : textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, size: 18, color: mutedColor),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Limpar',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryToggle extends StatelessWidget {
  const _DeliveryToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.circularCard,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Text(
          'Quero entrega no local',
          style: AppTextStyles.bodyLg,
        ),
        subtitle: Text(
          'O proprietário leva o carro até si',
          style: AppTextStyles.captionSm,
        ),
        secondary: Icon(
          Icons.local_shipping_rounded,
          color: value ? RentCarColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({required this.activeCount, required this.onTap});

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: Text(
          activeCount == 0
              ? 'Filtros avançados'
              : 'Filtros · $activeCount ativo(s)',
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.isLoading,
    required this.onTap,
    this.subtitle,
  });

  final bool isLoading;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onTap,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(isLoading ? 'A procurar…' : 'Ver veículos'),
          ),
        ),
      ),
    );
  }
}
