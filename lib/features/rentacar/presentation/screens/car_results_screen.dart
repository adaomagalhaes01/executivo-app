import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_search_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/car_search_provider.dart';
import '../widgets/car_card.dart';
import '../widgets/car_filter_sheet.dart';
import 'car_detail_screen.dart';

/// How the result list is ordered.
enum CarSortOption {
  recommended('Recomendados'),
  priceAsc('Menor preço'),
  priceDesc('Maior preço'),
  rating('Melhor avaliados');

  const CarSortOption(this.label);

  final String label;
}

/// Vehicle list for the current search, with sorting and filtering.
class CarResultsScreen extends StatefulWidget {
  const CarResultsScreen({super.key});

  @override
  State<CarResultsScreen> createState() => _CarResultsScreenState();
}

class _CarResultsScreenState extends State<CarResultsScreen> {
  CarSortOption _sort = CarSortOption.recommended;

  List<Car> _sorted(List<Car> cars) {
    final sorted = [...cars];
    switch (_sort) {
      case CarSortOption.recommended:
        sorted.sort((a, b) {
          if (a.isAvailable != b.isAvailable) return a.isAvailable ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
      case CarSortOption.priceAsc:
        sorted.sort(
          (a, b) =>
              a.pricing.pricePerDay.compareTo(b.pricing.pricePerDay),
        );
      case CarSortOption.priceDesc:
        sorted.sort(
          (a, b) =>
              b.pricing.pricePerDay.compareTo(a.pricing.pricePerDay),
        );
      case CarSortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return sorted;
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
  }

  void _openCar(Car car) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RentCarTheme.wrap(CarDetailScreen(carId: car.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarSearchProvider>();
    final criteria = provider.criteria;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Limpar filtros',
            onPressed: provider.filter.isEmpty
                ? null
                : () async {
                    await provider.applyFilter(CarSearchFilter.none);
                  },
            icon: const Icon(Icons.filter_alt_off_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _SummaryBar(
            count: provider.results.length,
            totalPerDay: provider.results.fold<double>(
              0,
              (sum, car) => sum + car.pricing.pricePerDay,
            ),
            sort: _sort,
            onSortChanged: (value) => setState(() => _sort = value),
            filterCount: provider.filter.activeCount,
            onFilterTap: _openFilters,
          ),
          if (criteria.hasDates)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 16,
                    color: RentCarColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${RentFormatters.compactDateRange(criteria.pickupDate!, criteria.returnDate!)} '
                      '· ${criteria.days} ${criteria.days == 1 ? 'dia' : 'dias'}'
                      '${criteria.location == null ? '' : ' · ${criteria.location!.label}'}',
                      style: AppTextStyles.captionSm,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(CarSearchProvider provider) {
    if (provider.isLoading) {
      return const ExecutiveStateView.loading(
        message: 'A procurar veículos disponíveis…',
      );
    }

    if (provider.status == CarSearchStatus.error) {
      return ExecutiveStateView.error(
        message: provider.errorMessage,
        onAction: provider.search,
      );
    }

    if (provider.results.isEmpty) {
      return ExecutiveStateView.empty(
        icon: Icons.search_off_rounded,
        title: 'Nenhum veículo encontrado',
        message: 'Ajuste as datas, o local ou os filtros para ver mais '
            'resultados.',
        actionLabel: 'Limpar filtros',
        onAction: () => provider.applyFilter(CarSearchFilter.none),
      );
    }

    final cars = _sorted(provider.results);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
      ),
      itemCount: cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final car = cars[index];
        return CarCard(
          car: car,
          showOwner: true,
          onTap: () => _openCar(car),
          onFavorite: () => provider.toggleFavorite(car.id),
        );
      },
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.count,
    required this.totalPerDay,
    required this.sort,
    required this.onSortChanged,
    required this.filterCount,
    required this.onFilterTap,
  });

  final int count;
  final double totalPerDay;
  final CarSortOption sort;
  final ValueChanged<CarSortOption> onSortChanged;
  final int filterCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count ${count == 1 ? 'veículo' : 'veículos'}',
                  style: AppTextStyles.titleSm.copyWith(color: textColor),
                ),
                Text(
                  count == 0
                      ? 'Sem resultados'
                      : 'a partir de ${RentFormatters.kwanza(totalPerDay / count)} / dia',
                  style: AppTextStyles.captionSm.copyWith(color: mutedColor),
                ),
              ],
            ),
          ),
          if (filterCount > 0) ...[
            Icon(Icons.filter_alt_rounded, size: 16, color: mutedColor),
            const SizedBox(width: 2),
            Text(
              '$filterCount',
              style: AppTextStyles.captionSm.copyWith(
                color: RentCarColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          IconButton(
            onPressed: onFilterTap,
            tooltip: 'Filtros avançados',
            icon: const Icon(Icons.tune_rounded),
          ),
          DropdownButton<CarSortOption>(
            value: sort,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            style: AppTextStyles.bodySm.copyWith(color: textColor),
            items: [
              for (final option in CarSortOption.values)
                DropdownMenuItem(value: option, child: Text(option.label)),
            ],
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
