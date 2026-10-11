import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/mock_rentacar_data.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/models/car_availability.dart';
import '../../../../core/models/car_listing_draft.dart';
import '../../../../core/models/car_rules.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_text_field.dart';
import '../providers/rentacar_owner_provider.dart';
import 'car_photo_grid.dart';
import 'location_picker_sheet.dart';

/// Dispatches the wizard body for the given [PublishStep].
class PublishStepBody extends StatelessWidget {
  const PublishStepBody({super.key, required this.step});

  final PublishStep step;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      PublishStep.vehicle => const _VehicleStep(),
      PublishStep.photos => const _PhotosStep(),
      PublishStep.pricing => const _PricingStep(),
      PublishStep.availability => const _AvailabilityStep(),
      PublishStep.location => const _LocationStep(),
      PublishStep.rules => const _RulesStep(),
      PublishStep.review => const _ReviewStep(),
    };
  }
}

// ─── Step 1: vehicle ─────────────────────────────────────────────────────────

class _VehicleStep extends StatelessWidget {
  const _VehicleStep();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;

    void update(CarListingDraft next) => provider.updateDraft(next);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ExecutiveTextField(
                label: 'Marca',
                hint: 'Toyota',
                initialValue: draft.brand,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => update(draft.copyWith(brand: value)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExecutiveTextField(
                label: 'Modelo',
                hint: 'Corolla',
                initialValue: draft.model,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => update(draft.copyWith(model: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ExecutiveTextField(
                label: 'Ano',
                hint: '2022',
                keyboardType: TextInputType.number,
                initialValue: draft.year?.toString(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) =>
                    update(draft.copyWith(year: int.tryParse(value))),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExecutiveTextField(
                label: 'Matrícula',
                hint: 'LD-123-AB',
                textCapitalization: TextCapitalization.characters,
                initialValue: draft.plate,
                onChanged: (value) => update(draft.copyWith(plate: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ExecutiveTextField(
                label: 'Cor',
                hint: 'Branco',
                initialValue: draft.color,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => update(draft.copyWith(color: value)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExecutiveTextField(
                label: 'Quilómetros',
                hint: '45000',
                keyboardType: TextInputType.number,
                initialValue: draft.mileageKm?.toString(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                onChanged: (value) => update(
                  draft.copyWith(mileageKm: int.tryParse(value)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _ChoiceGroup<TransmissionType>(
          label: 'Caixa',
          values: TransmissionType.values,
          selected: draft.transmission,
          labelOf: (value) => value.label,
          onSelected: (value) =>
              update(draft.copyWith(transmission: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ChoiceGroup<FuelType>(
          label: 'Combustível',
          values: FuelType.values,
          selected: draft.fuel,
          labelOf: (value) => value.label,
          onSelected: (value) => update(draft.copyWith(fuel: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ChoiceGroup<int>(
          label: 'Lugares',
          values: const [2, 4, 5, 7],
          selected: draft.seats,
          labelOf: (value) => '$value lugares',
          onSelected: (value) => update(draft.copyWith(seats: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ExecutiveTextField(
          label: 'Descrição',
          hint: 'Descreva o estado, acessórios e pontos fortes.',
          maxLines: 4,
          initialValue: draft.description,
          onChanged: (value) => update(draft.copyWith(description: value)),
        ),
      ],
    );
  }
}

// ─── Step 2: photos ──────────────────────────────────────────────────────────

class _PhotosStep extends StatelessWidget {
  const _PhotosStep();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!draft.hasCoverPhoto)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(18),
              borderRadius: AppRadius.circularCard,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_rounded,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'A primeira fotografia será a capa do anúncio.',
                    style: AppTextStyles.captionSm,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        CarPhotoGrid(
          images: draft.images,
          onChanged: (images) => provider.updateDraft(
            draft.copyWith(images: images),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '${draft.photoCount} fotografia(s) adicionada(s)',
          style: AppTextStyles.titleSm,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Anúncios com 4 ou mais fotos recebem o dobro de pedidos.',
          style: AppTextStyles.captionSm,
        ),
      ],
    );
  }
}

// ─── Step 3: pricing ─────────────────────────────────────────────────────────

class _PricingStep extends StatelessWidget {
  const _PricingStep();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;

    void update(CarListingDraft next) => provider.updateDraft(next);

    final dayRate = draft.pricePerDay ?? 0;
    final weekRate = draft.pricePerWeek ?? dayRate * 6;
    final monthRate = draft.pricePerMonth ?? dayRate * 26;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExecutiveTextField(
          label: 'Preço por dia (Kz)',
          hint: '25000',
          keyboardType: TextInputType.number,
          initialValue: draft.pricePerDay?.toStringAsFixed(0),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => update(
            draft.copyWith(pricePerDay: double.tryParse(value)),
          ),
          suffixText: 'Kz',
        ),
        if (dayRate > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.trending_down_rounded,
                size: 15,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                '7 dias: ${RentFormatters.kwanza(weekRate)} '
                '(${RentFormatters.perDay(weekRate / 7)}) · '
                '30 dias: ${RentFormatters.kwanza(monthRate)}',
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: ExecutiveTextField(
                label: 'Preço por semana',
                hint: 'Opcional',
                keyboardType: TextInputType.number,
                initialValue: draft.pricePerWeek?.toStringAsFixed(0),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => update(
                  draft.copyWith(pricePerWeek: double.tryParse(value)),
                ),
                suffixText: 'Kz',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExecutiveTextField(
                label: 'Preço por mês',
                hint: 'Opcional',
                keyboardType: TextInputType.number,
                initialValue: draft.pricePerMonth?.toStringAsFixed(0),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => update(
                  draft.copyWith(pricePerMonth: double.tryParse(value)),
                ),
                suffixText: 'Kz',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: ExecutiveTextField(
                label: 'Taxa de serviço (Kz)',
                hint: '5000',
                keyboardType: TextInputType.number,
                initialValue: draft.serviceFee?.toStringAsFixed(0),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => update(
                  draft.copyWith(serviceFee: double.tryParse(value)),
                ),
                suffixText: 'Kz',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExecutiveTextField(
                label: 'Caução (Kz)',
                hint: '50000',
                keyboardType: TextInputType.number,
                initialValue: draft.deposit?.toStringAsFixed(0),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) =>
                    update(draft.copyWith(deposit: double.tryParse(value))),
                suffixText: 'Kz',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Características', style: AppTextStyles.titleMd),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Selecione tudo o que o veículo oferece.',
          style: AppTextStyles.captionSm,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final feature in MockRentCarData.features)
              _FeatureToggle(
                label: feature,
                selected: draft.features.contains(feature),
                onTap: () {
                  final next = {...draft.features};
                  if (!next.remove(feature)) next.add(feature);
                  update(draft.copyWith(features: next.toList()));
                },
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Step 4: availability ────────────────────────────────────────────────────

class _AvailabilityStep extends StatelessWidget {
  const _AvailabilityStep();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;
    final availability = draft.availability;
    final blocked = availability.blockedPeriods.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.circularCard,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: availability.status == AvailabilityStatus.available,
                onChanged: (value) => provider.updateDraft(
                  draft.copyWith(
                    availability: availability.copyWith(
                      status: value
                          ? AvailabilityStatus.available
                          : AvailabilityStatus.unavailable,
                    ),
                  ),
                ),
                title: Text('Disponível para aluguer', style: AppTextStyles.bodyLg),
                subtitle: Text(
                  'Desligue para manter o anúncio visível mas fora das '
                  'pesquisas.',
                  style: AppTextStyles.captionSm,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text('Datas indisponíveis', style: AppTextStyles.titleMd),
            ),
            Text(
              blocked == 0 ? 'Nenhuma' : '$blocked período(s)',
              style: AppTextStyles.captionSm,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Pode bloquear datas mais tarde em "Os meus carros".',
          style: AppTextStyles.captionSm,
        ),
        const SizedBox(height: AppSpacing.md),
        if (blocked == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              color: RentCarColors.primary.withAlpha(12),
              borderRadius: AppRadius.circularCard,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: RentCarColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sem datas bloqueadas — o carro está livre.',
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
          )
        else
          for (final period in availability.blockedPeriods)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_busy_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      RentFormatters.compactDateRange(period.start, period.end),
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

// ─── Step 5: location ────────────────────────────────────────────────────────

class _LocationStep extends StatelessWidget {
  const _LocationStep();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;
    final location = draft.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.circularCard,
              border: Border.all(color: RentCarColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place_rounded, color: RentCarColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        location.label,
                        style: AppTextStyles.titleSm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(location.address, style: AppTextStyles.captionSm),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: AppRadius.circularCard,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.map_rounded, size: 30),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Nenhum local escolhido',
                  style: AppTextStyles.titleSm,
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await LocationPickerSheet.show(
                context,
                selected: location,
              );
              if (picked == null || !context.mounted) return;
              provider.updateDraft(draft.copyWith(location: picked));
            },
            icon: Icon(
              location == null
                  ? Icons.add_location_alt_rounded
                  : Icons.edit_location_rounded,
            ),
            label: Text(
              location == null ? 'Escolher local' : 'Alterar local',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 6: rules ───────────────────────────────────────────────────────────

class _RulesStep extends StatelessWidget {
  const _RulesStep();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;
    final rules = draft.rules;

    void updateRules(CarRules next) =>
        provider.updateDraft(draft.copyWith(rules: next));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExecutiveTextField(
          label: 'Quilometragem incluída por dia',
          hint: '150',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: rules.dailyKilometreLimit?.toString(),
          onChanged: (value) => updateRules(
            rules.copyWith(dailyKilometreLimit: int.tryParse(value)),
          ),
          suffixText: 'km',
        ),
        const SizedBox(height: AppSpacing.md),
        ExecutiveTextField(
          label: 'Preço por quilómetro extra',
          hint: '500',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: rules.extraKilometrePrice?.toStringAsFixed(0),
          onChanged: (value) => updateRules(
            rules.copyWith(extraKilometrePrice: double.tryParse(value)),
          ),
          suffixText: 'Kz/km',
        ),
        const SizedBox(height: AppSpacing.lg),
        _Counter(
          label: 'Idade mínima do condutor',
          value: rules.minimumAge,
          min: 18,
          max: 40,
          onChanged: (value) =>
              updateRules(rules.copyWith(minimumAge: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ExecutiveTextField(
          label: 'Política de combustível',
          hint: 'Devolver com o depósito cheio',
          initialValue: rules.fuelPolicy,
          onChanged: (value) =>
              updateRules(rules.copyWith(fuelPolicy: value)),
        ),
        const SizedBox(height: AppSpacing.md),
        ExecutiveTextField(
          label: 'Política de cancelamento',
          hint: 'Gratuito até 24h antes',
          initialValue: rules.cancellationPolicy,
          onChanged: (value) =>
              updateRules(rules.copyWith(cancellationPolicy: value)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ExecutiveTextField(
          label: 'Notas para o cliente',
          hint: 'Ex.: nãoSmoking, apenas entregas',
          maxLines: 3,
          initialValue: rules.notes,
          onChanged: (value) => updateRules(rules.copyWith(notes: value)),
        ),
      ],
    );
  }
}

// ─── Step 7: review ──────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<RentCarOwnerProvider>().draft;
    final cover = draft.coverImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cover != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(cover.path, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(draft.title, style: AppTextStyles.headingSm),
        Text(
          '${draft.year ?? '—'} · ${draft.color.isEmpty ? '—' : draft.color} · '
          '${draft.plate.isEmpty ? '—' : draft.plate.toUpperCase()}',
          style: AppTextStyles.captionSm,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ReviewRow(
          icon: Icons.settings_rounded,
          label: 'Caixa / combustível',
          value: draft.transmission == null || draft.fuel == null
              ? '—'
              : '${draft.transmission!.label} · ${draft.fuel!.label}',
        ),
        _ReviewRow(
          icon: Icons.event_seat_rounded,
          label: 'Lugares',
          value: draft.seats?.toString() ?? '—',
        ),
        _ReviewRow(
          icon: Icons.payments_rounded,
          label: 'Preço por dia',
          value: RentFormatters.perDay(draft.pricePerDay ?? 0),
        ),
        _ReviewRow(
          icon: Icons.place_rounded,
          label: 'Local',
          value: draft.location?.label ?? 'Não escolhido',
        ),
        _ReviewRow(
          icon: Icons.photo_library_rounded,
          label: 'Fotografias',
          value: '${draft.photoCount}',
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: RentCarColors.primary.withAlpha(14),
            borderRadius: AppRadius.circularCard,
          ),
          child: Row(
            children: [
              const Icon(Icons.published_with_changes_rounded, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Ao publicar, o anúncio fica visível nas pesquisas '
                  'imediatamente.',
                  style: AppTextStyles.captionSm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RentCarColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
          Text(value, style: AppTextStyles.titleSm),
        ],
      ),
    );
  }
}

// ─── Shared pieces ───────────────────────────────────────────────────────────

/// Horizontal single-select group, used for gearbox, fuel and seats.
class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSm),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final value in values)
              _ChoiceChip(
                label: labelOf(value),
                selected: selected == value,
                onTap: () => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
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

class _FeatureToggle extends StatelessWidget {
  const _FeatureToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}

/// Small stepper used for bathrooms and minimum age.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 20,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyLg)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: (value ?? min) > min
                    ? () => onChanged((value ?? min) - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                value?.toString() ?? '—',
                style: AppTextStyles.titleSm,
              ),
              IconButton(
                onPressed: (value ?? min) < max
                    ? () => onChanged((value ?? min) + 1)
                    : null,
                icon: const Icon(Icons.add_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
