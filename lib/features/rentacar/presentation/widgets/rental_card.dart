import 'package:flutter/material.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/rental.dart';
import '../../../../core/models/rental_request.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_badge.dart';

/// Maps a booking status to the badge tone used across the module.
ExecutiveBadgeTone rentalStatusTone(RentalStatus status) => switch (status) {
      RentalStatus.pending => ExecutiveBadgeTone.warning,
      RentalStatus.confirmed => ExecutiveBadgeTone.success,
      RentalStatus.rejected => ExecutiveBadgeTone.danger,
      RentalStatus.cancelled => ExecutiveBadgeTone.neutral,
      RentalStatus.completed => ExecutiveBadgeTone.info,
    };

/// Booking card used by "Minhas reservas".
///
/// Shows the vehicle thumbnail, the period, the price and the status so the
/// user can tell at a glance what is coming up and what it cost.
class RentalCard extends StatelessWidget {
  const RentalCard({
    super.key,
    required this.rental,
    this.onTap,
    this.onCancel,
    this.compact = false,
  });

  final Rental rental;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  /// Drops the price line — used in the dense upcoming list.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final car = rental.car;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: AppRadius.circularCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.circularCard,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(car: car),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSm.copyWith(
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rental.status.label,
                          style: AppTextStyles.captionSm.copyWith(
                            color: rental.status == RentalStatus.pending
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExecutiveBadge(
                    label: rental.status.label,
                    tone: rentalStatusTone(rental.status),
                    icon: rental.status.icon,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _Period(
                start: rental.pickupDate,
                end: rental.returnDate,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    rental.delivered
                        ? Icons.local_shipping_rounded
                        : Icons.place_rounded,
                    size: 14,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rental.handoverLocation.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.captionSm,
                    ),
                  ),
                  if (!compact)
                    Text(
                      RentFormatters.kwanza(rental.quote.total),
                      style: AppTextStyles.titleSm.copyWith(
                        color: RentCarColors.primary,
                      ),
                    ),
                ],
              ),
              if (onCancel != null && rental.canBeCancelled) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final cover = car.coverImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 60,
        child: cover == null
            ? Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.directions_car_rounded),
              )
            : Image.asset(
                cover.path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.directions_car_rounded),
                ),
              ),
      ),
    );
  }
}

class _Period extends StatelessWidget {
  const _Period({
    required this.start,
    required this.end,
    required this.textColor,
    required this.mutedColor,
  });

  final DateTime start;
  final DateTime end;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.date_range_rounded, size: 14, color: RentCarColors.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            RentFormatters.compactDateRange(start, end),
            style: AppTextStyles.bodySm.copyWith(color: textColor),
          ),
        ),
        Text(
          '${_days()} ${_days() == 1 ? 'dia' : 'dias'}',
          style: AppTextStyles.captionSm.copyWith(color: mutedColor),
        ),
      ],
    );
  }

  int _days() {
    final diff = DateTime(end.year, end.month, end.day)
        .difference(DateTime(start.year, start.month, start.day))
        .inDays;
    return diff < 1 ? 1 : diff;
  }
}

/// Card for an incoming request, shown to the owner.
class RentalRequestCard extends StatelessWidget {
  const RentalRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onAccept,
    this.onDecline,
  });

  final RentalRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final rental = request.rental;
    final renter = request.renter;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: AppRadius.circularCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.circularCard,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: RentCarColors.primary.withAlpha(28),
                    child: Text(
                      renter.name.characters.first,
                      style: AppTextStyles.titleSm.copyWith(
                        color: RentCarColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                renter.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleSm,
                              ),
                            ),
                            if (renter.isVerified) ...[
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: RentCarColors.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${renter.rating.toStringAsFixed(1)} · ${renter.reviewCount} avaliações',
                          style: AppTextStyles.captionSm,
                        ),
                      ],
                    ),
                  ),
                  ExecutiveBadge(
                    label: request.status.label,
                    tone: rentalStatusTone(request.status),
                    icon: request.status.icon,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rental.car.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLg,
                        ),
                        Text(
                          RentFormatters.compactDateRange(
                            rental.pickupDate,
                            rental.returnDate,
                          ),
                          style: AppTextStyles.captionSm,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    RentFormatters.kwanza(rental.quote.total),
                    style: AppTextStyles.titleSm.copyWith(
                      color: RentCarColors.primary,
                    ),
                  ),
                ],
              ),
              if (request.note.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '“${request.note}”',
                  style: AppTextStyles.captionSm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (onAccept != null && request.canBeAnswered) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        child: const Text('Recusar'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        child: const Text('Aceitar pedido'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
