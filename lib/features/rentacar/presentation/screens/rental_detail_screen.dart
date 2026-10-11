import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/rental.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_badge.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/rentacar_rental_provider.dart';
import '../widgets/car_gallery.dart';
import '../widgets/price_breakdown.dart';

/// Everything about one booking, with the actions still available on it.
///
/// Accepts a rental id so the screen can be reopened from a notification
/// without depending on the previous route.
class RentalDetailScreen extends StatefulWidget {
  const RentalDetailScreen({super.key, required this.rentalId});

  final String rentalId;

  @override
  State<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RentCarRentalProvider>();
      if (provider.myRentals.isEmpty) provider.loadMyRentals();
    });
  }

  Rental? _find(List<Rental> rentals) {
    for (final rental in rentals) {
      if (rental.id == widget.rentalId) return rental;
    }
    return null;
  }

  Future<void> _cancel(Rental rental) async {
    final provider = context.read<RentCarRentalProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.cancelRental(rental.id);
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? 'Reserva cancelada.' : 'Operação falhou.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarRentalProvider>();
    final rental = _find(provider.myRentals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da reserva'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: rental == null
          ? ExecutiveStateView.error(
              message: 'Esta reserva já não está disponível.',
              actionLabel: 'Voltar',
              onAction: () => Navigator.of(context).maybePop(),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                CarGallery(images: rental.car.images, height: 220),
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
                            child: Text(
                              rental.car.title,
                              style: AppTextStyles.headingSm,
                            ),
                          ),
                          ExecutiveBadge(
                            label: rental.status.label,
                            tone: _toneFor(rental.status),
                            icon: rental.status.icon,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        rental.status.description,
                        style: AppTextStyles.captionSm,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _InfoCard(rental: rental),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Pagamento', style: AppTextStyles.titleMd),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: AppRadius.circularCard,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: PriceBreakdown(quote: rental.quote, dense: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: rental == null || !rental.canBeCancelled
          ? null
          : Container(
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
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: provider.isSubmitting
                        ? null
                        : () => _cancel(rental),
                    icon: const Icon(Icons.event_busy_rounded, size: 18),
                    label: const Text('Cancelar reserva'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  static ExecutiveBadgeTone _toneFor(RentalStatus status) => switch (status) {
        RentalStatus.pending => ExecutiveBadgeTone.warning,
        RentalStatus.confirmed => ExecutiveBadgeTone.success,
        RentalStatus.rejected => ExecutiveBadgeTone.danger,
        RentalStatus.cancelled => ExecutiveBadgeTone.neutral,
        RentalStatus.completed => ExecutiveBadgeTone.info,
      };
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rental});

  final Rental rental;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.circularCard,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _Row(
            icon: Icons.login_rounded,
            label: 'Levantamento',
            value: RentFormatters.shortDateTime(rental.pickupDate),
          ),
          _Row(
            icon: Icons.logout_rounded,
            label: 'Devolução',
            value: RentFormatters.shortDateTime(rental.returnDate),
          ),
          _Row(
            icon: rental.delivered
                ? Icons.local_shipping_rounded
                : Icons.place_rounded,
            label: rental.delivered ? 'Entrega' : 'Local',
            value: rental.handoverLocation.address,
          ),
          _Row(
            icon: Icons.person_rounded,
            label: 'Proprietário',
            value: rental.car.owner.name,
          ),
          _Row(
            icon: Icons.receipt_long_rounded,
            label: 'Pedido criado',
            value: RentFormatters.shortDateTime(rental.createdAt),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: RentCarColors.primary),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 96,
            child: Text(label, style: AppTextStyles.captionSm),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}