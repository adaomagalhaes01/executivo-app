import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/rental.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../providers/rentacar_rental_provider.dart';
import 'rental_detail_screen.dart';

/// Success screen shown right after a booking request is sent.
///
/// States plainly that the request is still pending owner acceptance, and
/// offers the two things the user might want next: track it or cancel it.
class CarBookingConfirmationScreen extends StatelessWidget {
  const CarBookingConfirmationScreen({super.key, required this.rental});

  final Rental rental;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Fechar',
                ),
              ),
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(24),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 44,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Pedido enviado',
                style: AppTextStyles.headingMd.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${rental.car.title} · ${rental.car.location.label}',
                style: AppTextStyles.bodyLg.copyWith(color: mutedColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'O proprietário costuma responder em ~${rental.car.owner.typicalResponseMinutes} minutos. '
                'A reserva fica pendente até ele aceitar.',
                style: AppTextStyles.bodyMd.copyWith(color: mutedColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppRadius.circularCard,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Levantamento',
                      value: RentFormatters.shortDate(rental.pickupDate),
                    ),
                    _InfoRow(
                      label: 'Devolução',
                      value: RentFormatters.shortDate(rental.returnDate),
                    ),
                    _InfoRow(
                      label: rental.delivered
                          ? 'Entrega em'
                          : 'Local',
                      value: rental.handoverLocation.label,
                    ),
                    _InfoRow(
                      label: 'Total',
                      value: RentFormatters.kwanza(rental.quote.total),
                      emphasise: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => RentCarTheme.wrap(
                        RentalDetailScreen(rentalId: rental.id),
                      ),
                    ),
                  ),
                  child: const Text('Acompanhar pedido'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer<RentCarRentalProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await provider.cancelRental(rental.id);
                        if (context.mounted) navigator.pop();
                      },
                      child: const Text('Cancelar pedido'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMd),
          ),
          Text(
            value,
            style: emphasise
                ? AppTextStyles.titleSm.copyWith(color: RentCarColors.primary)
                : AppTextStyles.titleSm,
          ),
        ],
      ),
    );
  }
}
