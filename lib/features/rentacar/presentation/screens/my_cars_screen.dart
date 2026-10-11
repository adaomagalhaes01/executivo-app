import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_badge.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/rentacar_owner_provider.dart';
import '../providers/rentacar_rental_provider.dart';
import '../widgets/rentcar_action_card.dart';
import 'car_publish_intro_screen.dart';
import 'my_car_manage_screen.dart';

/// "Os meus carros": every vehicle the signed-in user has published.
class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentCarOwnerProvider>().loadMyCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<RentCarOwnerProvider>();
    final pendingCounts = context.watch<RentCarRentalProvider>().pendingCountByCar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Os meus carros'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _body(owner, pendingCounts),
    );
  }

  Widget _body(
    RentCarOwnerProvider owner,
    Map<String, int> pendingCounts,
  ) {
    if (owner.isLoading && owner.myCars.isEmpty) {
      return const ExecutiveStateView.loading(
        message: 'A carregar os seus veículos…',
      );
    }

    if (owner.myCars.isEmpty) {
      return ExecutiveStateView.empty(
        icon: Icons.directions_car_rounded,
        title: 'Ainda não tem veículos',
        message: 'Publique o seu carro para começar a receber pedidos.',
        actionLabel: 'Publicar carro',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RentCarTheme.wrap(const CarPublishIntroScreen()),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: owner.loadMyCars,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Ativos',
                  value: owner.activeCarsCount,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Stat(
                  label: 'Pausados',
                  value: owner.pausedCarsCount,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Stat(
                  label: 'Pedidos',
                  value: pendingCounts.values.fold(0, (a, b) => a + b),
                  color: RentCarColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final car in owner.myCars) ...[
            _OwnerCarCard(
              car: car,
              pendingCount: pendingCounts[car.id] ?? 0,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RentCarTheme.wrap(
                    MyCarManageScreen(carId: car.id),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.circularCard,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.headingSm.copyWith(color: color),
          ),
          Text(label.toUpperCase(), style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}

class _OwnerCarCard extends StatelessWidget {
  const _OwnerCarCard({
    required this.car,
    required this.pendingCount,
    required this.onTap,
  });

  final Car car;
  final int pendingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RentCarActionCard(
      icon: Icons.directions_car_rounded,
      title: car.title,
      subtitle: '${car.plate} · ${RentFormatters.perDay(car.pricing.pricePerDay)}',
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: RentCarColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$pendingCount',
                style: AppTextStyles.captionSm.copyWith(color: Colors.white),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
          ExecutiveBadge(
            label: car.status.label,
            tone: car.status == CarStatus.active
                ? ExecutiveBadgeTone.success
                : ExecutiveBadgeTone.neutral,
            dense: true,
          ),
        ],
      ),
    );
  }
}
