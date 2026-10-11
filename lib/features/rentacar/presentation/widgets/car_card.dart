import 'package:flutter/material.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/car_attributes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_badge.dart';
import 'vehicle_image_view.dart';

/// Listing card: a large photograph on top, the identity and specs below.
///
/// The photo takes roughly half the card so the vehicle is the first thing the
/// renter perceives — everything else is secondary information.
class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onFavorite,
    this.showOwner = false,
    this.compact = false,
  });

  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  /// Adds the owner name row under the price.
  final bool showOwner;

  /// Renders the favourite button — used by search results.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkElevated : AppColors.border;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: AppRadius.circularCardLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.circularCardLg,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CarImageHeader(
                car: car,
                compact: compact,
                onFavorite: onFavorite,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.cardPadding,
                  14,
                  AppSpacing.cardPadding,
                  AppSpacing.cardPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            car.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLg.copyWith(
                              color: textColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (car.rating > 0) _RatingPill(rating: car.rating),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.specsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    size: 14,
                                    color:
                                        isDark ? AppColors.textOnDarkSecondary
                                            : AppColors.iconSubtle,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      car.location.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                        color: mutedColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${RentFormatters.kwanza(car.pricing.pricePerDay)} / dia',
                                style: AppTextStyles.titleLg.copyWith(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onTap != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: RentCarColors.primary,
                              borderRadius: AppRadius.circularButton,
                            ),
                            child: Text(
                              'Ver detalhes',
                              style: AppTextStyles.labelMd.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (showOwner) ...[
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.surfaceVariant
                            : AppColors.divider,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: mutedColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              car.owner.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!car.isAvailable)
                            ExecutiveBadge(
                              label: car.status.label,
                              tone: ExecutiveBadgeTone.neutral,
                              dense: true,
                            ),
                        ],
                      ),
                    ],
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

class _CarImageHeader extends StatelessWidget {
  const _CarImageHeader({
    required this.car,
    required this.compact,
    required this.onFavorite,
  });

  final Car car;
  final bool compact;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 168.0 : 200.0;
    final cover = car.coverImage;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cover != null)
            VehicleImageView(image: cover, fit: BoxFit.cover)
          else
            const ColoredBox(
              color: AppColors.surfaceVariant,
              child: Center(
                child: Icon(
                  Icons.directions_car_outlined,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
              ),
            ),

          // Scrim so the badges stay readable over bright photos.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 76,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(90),
                      Colors.black.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 12,
            top: 12,
            child: Row(
              children: [
                if (!car.isAvailable)
                  ExecutiveBadge(
                    label: car.status.label,
                    tone: ExecutiveBadgeTone.neutral,
                    dense: true,
                  )
                else if (car.isElectric)
                  const ExecutiveBadge(
                    label: 'Elétrico',
                    tone: ExecutiveBadgeTone.info,
                    icon: Icons.bolt_rounded,
                    dense: true,
                  ),
              ],
            ),
          ),

          if (onFavorite != null)
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.black.withAlpha(70),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onFavorite,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      car.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: car.isFavorite
                          ? RentCarColors.primary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Photo count pill, bottom right.
          if (car.images.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: AppRadius.circularChip,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${car.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(24),
        borderRadius: AppRadius.circularChip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
