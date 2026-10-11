import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/models/car_rules.dart';
import '../../../../core/models/rental_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/car_search_provider.dart';
import '../widgets/car_gallery.dart';
import '../widgets/car_spec_tile.dart';
import 'car_booking_screen.dart';

/// Full listing: photos, specs, features, rules, location and the owner.
class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({super.key, required this.carId});

  final String carId;

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  Car? _car;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<CarSearchProvider>();
    if (provider.catalogue.isEmpty) await provider.loadCatalogue();
    if (!mounted) return;
    setState(() {
      _car = provider.carById(widget.carId);
      _isLoading = false;
    });
  }

  void _book(Car car) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RentCarTheme.wrap(CarBookingScreen(carId: car.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final car = _car;

    return Scaffold(
      appBar: AppBar(
        title: Text(car?.title ?? 'Veículo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (car != null)
            IconButton(
              tooltip: car.isFavorite ? 'Remover dos favoritos' : 'Favorito',
              onPressed: () =>
                  context.read<CarSearchProvider>().toggleFavorite(car.id),
              icon: Icon(
                car.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: car.isFavorite ? AppColors.error : null,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const ExecutiveStateView.loading()
          : car == null
              ? ExecutiveStateView.error(
                  message: 'Este veículo já não está disponível.',
                  actionLabel: 'Voltar',
                  onAction: () => Navigator.of(context).maybePop(),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  children: [
                    CarGallery(
                      images: car.images,
                      heroPrefix: 'car-${car.id}',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      car.title,
                                      style: AppTextStyles.headingSm.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      car.ageLabel,
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _PriceBlock(car: car),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _Badges(car: car),
                          const SizedBox(height: AppSpacing.xl),
                          CarSpecsGrid(
                            tiles: [
                              CarSpecTile(
                                icon: Icons.settings_rounded,
                                value: car.transmission.label,
                                label: 'Caixa',
                              ),
                              CarSpecTile(
                                icon: Icons.local_gas_station_rounded,
                                value: car.fuel.label,
                                label: 'Combustível',
                              ),
                              CarSpecTile(
                                icon: Icons.airline_seat_recline_normal_rounded,
                                value: '${car.seats}',
                                label: 'Lugares',
                              ),
                              CarSpecTile(
                                icon: Icons.speed_rounded,
                                value: '${car.mileageKm ~/ 1000}k km',
                                label: 'Quilómetros',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          if (car.description.isNotEmpty) ...[
                            const _SectionHeader('Descrição'),
                            Text(
                              car.description,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: mutedColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                          if (car.features.isNotEmpty) ...[
                            const _SectionHeader('Características'),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final feature in car.features)
                                  _FeaturePill(label: feature),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                          const _SectionHeader('Local de levantamento'),
                          _LocationRow(location: car.location),
                          const SizedBox(height: AppSpacing.xl),
                          const _SectionHeader('Regras de aluguer'),
                          _Rules(rules: car.rules),
                          const SizedBox(height: AppSpacing.xl),
                          const _SectionHeader('Proprietário'),
                          _OwnerCard(car: car),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: car == null
          ? null
          : _BookingBar(
              car: car,
              onBook: () => _book(car),
            ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          RentFormatters.kwanza(car.pricing.pricePerDay),
          style: AppTextStyles.headingSm.copyWith(color: RentCarColors.primary),
        ),
        Text('por dia', style: AppTextStyles.captionSm),
      ],
    );
  }
}

class _Badges extends StatelessWidget {
  const _Badges({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (car.rating > 0)
          _FeaturePill(
            label: '${car.rating.toStringAsFixed(1)} · ${car.reviewsCount} avaliações',
            icon: Icons.star_rounded,
            highlighted: true,
          ),
        _FeaturePill(
          label: car.isAvailable ? 'Disponível agora' : car.status.label,
          icon: car.isAvailable
              ? Icons.check_circle_rounded
              : Icons.schedule_rounded,
          highlighted: car.isAvailable,
        ),
        if (car.pricing.deposit > 0)
          _FeaturePill(
            label: 'Caução ${RentFormatters.kwanzaCompact(car.pricing.deposit)}',
            icon: Icons.shield_rounded,
          ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.label,
    this.icon,
    this.highlighted = false,
  });

  final String label;
  final IconData? icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? RentCarColors.primary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(highlighted ? 18 : 10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.captionSm.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(text, style: AppTextStyles.titleMd),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location});

  final RentalLocation location;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: RentCarColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.place_rounded, color: RentCarColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location.label, style: AppTextStyles.bodyLg),
              Text(location.address, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }
}

class _Rules extends StatelessWidget {
  const _Rules({required this.rules});

  final CarRules rules;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String)>[
      if (rules.dailyKilometreLimit != null)
        (
          Icons.speed_rounded,
          '${rules.dailyKilometreLimit} km incluídos por dia'
              '${rules.extraKilometrePrice == null ? '' : ' · excedente ${RentFormatters.kwanza(rules.extraKilometrePrice!)}/km'}'
        ),
      if (rules.minimumAge != null)
        (Icons.verified_user_rounded, 'Idade mínima ${rules.minimumAge} anos'),
      for (final document in rules.requiredDocuments)
        (Icons.description_rounded, document),
      if (rules.fuelPolicy != null)
        (Icons.local_gas_station_rounded, rules.fuelPolicy!),
      if (rules.cancellationPolicy != null)
        (Icons.event_busy_rounded, rules.cancellationPolicy!),
    ];

    if (rows.isEmpty) {
      return Text(
        'Sem regras adicionais. Confirme as condições com o proprietário.',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(row.$1, size: 16, color: RentCarColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(row.$2, style: AppTextStyles.bodyMd),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final owner = car.owner;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.circularCard,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: RentCarColors.primary.withAlpha(28),
            child: Text(
              owner.name.characters.first,
              style: AppTextStyles.titleSm.copyWith(color: RentCarColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        owner.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSm,
                      ),
                    ),
                    if (owner.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: RentCarColors.primary,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${owner.totalRentals} alugueres · responde em ~${owner.typicalResponseMinutes} min',
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
          ),
          if (owner.rating > 0)
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
                const SizedBox(width: 2),
                Text(
                  owner.rating.toStringAsFixed(1),
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.car, required this.onBook});

  final Car car;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  RentFormatters.perDay(car.pricing.pricePerDay),
                  style: AppTextStyles.titleSm.copyWith(
                    color: RentCarColors.primary,
                  ),
                ),
                if (car.pricing.serviceFee > 0)
                  Text(
                    '+ ${RentFormatters.kwanza(car.pricing.serviceFee)} taxas',
                    style: AppTextStyles.captionSm,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: car.isAvailable ? onBook : null,
                child: Text(
                  car.isAvailable ? 'Reservar' : 'Indisponível',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
