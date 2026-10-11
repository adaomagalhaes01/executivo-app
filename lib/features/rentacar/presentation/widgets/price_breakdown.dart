import 'package:flutter/material.dart';

import '../../../../core/models/rental_pricing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';

/// Price breakdown shown on the booking and review screens.
///
/// `25.000 Kz × 3 dias` / `75.000 Kz`, plus the optional service fee and the
/// refundable deposit — clearly separated from the amount actually charged.
class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({
    super.key,
    required this.quote,
    this.showDailyLine = true,
    this.dense = false,
  });

  final RentalQuote quote;
  final bool showDailyLine;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final dividerColor =
        isDark ? AppColors.darkElevated : AppColors.divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDailyLine)
          _PriceRow(
            label: '${RentFormatters.kwanza(quote.dailyRate)} × ${quote.days} '
                '${quote.days == 1 ? 'dia' : 'dias'}',
            value: RentFormatters.kwanza(quote.subtotal),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        if (quote.hasFees) ...[
          _PriceRow(
            label: 'Taxas de serviço',
            value: RentFormatters.kwanza(quote.fees),
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ],
        if (quote.hasDeposit) ...[
          _PriceRow(
            label: 'Caução (reembolsável)',
            value: RentFormatters.kwanza(quote.deposit),
            textColor: mutedColor,
            mutedColor: mutedColor,
          ),
        ],
        SizedBox(height: dense ? AppSpacing.sm : AppSpacing.sm),
        Divider(height: 1, color: dividerColor),
        SizedBox(height: dense ? AppSpacing.sm : AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Total',
                style: AppTextStyles.titleMd.copyWith(color: textColor),
              ),
            ),
            Text(
              RentFormatters.kwanza(quote.total),
              style: AppTextStyles.headingSm.copyWith(
                color: RentCarColors.primary,
                fontSize: dense ? 20 : 22,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMd.copyWith(color: mutedColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleSm.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}