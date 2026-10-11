import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/models/car_availability.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/rentacar_owner_provider.dart';
import 'car_availability_sheet.dart';

/// Owner view of one listing: preview, status and availability management.
class MyCarManageScreen extends StatefulWidget {
  const MyCarManageScreen({
    super.key,
    required this.carId,
    this.justPublished = false,
  });

  final String carId;

  /// Highlights the availability section right after publishing.
  final bool justPublished;

  @override
  State<MyCarManageScreen> createState() => _MyCarManageScreenState();
}

class _MyCarManageScreenState extends State<MyCarManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RentCarOwnerProvider>();
      if (provider.myCars.isEmpty) provider.loadMyCars();
    });
  }

  Car? get _car => context.read<RentCarOwnerProvider>().carById(widget.carId);

  Future<void> _toggleStatus() async {
    final car = _car;
    if (car == null) return;
    await context.read<RentCarOwnerProvider>().toggleListingStatus(car.id);
  }

  Future<void> _toggleAvailability() async {
    final car = _car;
    if (car == null) return;
    await context.read<RentCarOwnerProvider>().setAvailability(
          car.id,
          car.availability.status != AvailabilityStatus.available,
        );
  }

  Future<void> _manageDates() async {
    final car = _car;
    if (car == null) return;
    final result = await CarAvailabilitySheet.show(context, car: car);
    if (result == null || !mounted) return;
    await context.read<RentCarOwnerProvider>().loadMyCars();
    // ignore: unnecessary_statements
  }

  Future<void> _delete() async {
    final car = _car;
    if (car == null) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover anúncio'),
        content: Text(
          'O anúncio de ${car.title} deixa de estar visível nas pesquisas. '
          'As reservas já existentes mantêm-se.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Manter'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<RentCarOwnerProvider>().deleteListing(car.id);
    messenger.showSnackBar(
      const SnackBar(content: Text('Anúncio removido.')),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final car = _car;
    if (car == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gerir veículo'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const ExecutiveStateView.empty(
          icon: Icons.directions_car_rounded,
          title: 'Veículo não encontrado',
          message: 'Este anúncio pode ter sido removido.',
        ),
      );
    }

    final isAvailable = car.availability.status == AvailabilityStatus.available;
    final blocked = car.availability.blockedPeriods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir veículo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: car.status == CarStatus.active
                ? 'Pausar anúncio'
                : 'Reativar anúncio',
            onPressed: _toggleStatus,
            icon: Icon(
              car.status == CarStatus.active
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          if (widget.justPublished)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(18),
                borderRadius: AppRadius.circularCard,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Anúncio publicado com sucesso.',
                      style: AppTextStyles.captionSm,
                    ),
                  ),
                ],
              ),
            ),
          _Preview(car: car),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: isAvailable,
            onChanged: (_) => _toggleAvailability(),
            title: Text('Disponível para reserva', style: AppTextStyles.bodyLg),
            subtitle: Text(
              isAvailable
                  ? 'Aparece nos resultados de pesquisa'
                  : 'Visível, mas não pode ser reservado',
              style: AppTextStyles.captionSm,
            ),
            secondary: Icon(
              isAvailable
                  ? Icons.check_circle_rounded
                  : Icons.pause_circle_rounded,
              color: isAvailable ? AppColors.success : AppColors.warning,
            ),
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Datas bloqueadas',
                  style: AppTextStyles.titleMd,
                ),
              ),
              TextButton.icon(
                onPressed: _manageDates,
                icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                label: const Text('Gerir'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (blocked.isEmpty)
            Text(
              'Sem datas bloqueadas — o carro está livre durante todo o período.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            for (final period in blocked)
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
                        RentFormatters.compactDateRange(
                          period.start,
                          period.end,
                        ),
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                  ],
                ),
              ),
          const Divider(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Remover anúncio'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final cover = car.coverImage;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: AppRadius.circularCard,
      child: InkWell(
        borderRadius: AppRadius.circularCard,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 70,
                  child: cover == null
                      ? Container(color: AppColors.surfaceVariant)
                      : Image.asset(
                          cover.path,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Container(color: AppColors.surfaceVariant),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.title, style: AppTextStyles.titleMd),
                    Text(
                      '${car.plate} · ${RentFormatters.perDay(car.pricing.pricePerDay)}',
                      style: AppTextStyles.captionSm,
                    ),
                    Text(
                      '${car.location.label} · ${car.images.length} fotos',
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
