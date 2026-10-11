import 'package:flutter/material.dart';

import '../../../../core/models/car.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import 'my_car_manage_screen.dart';

/// Confirmation shown after a listing goes live.
///
/// Deliberately points at the next useful action — managing availability — so
/// the owner is not dropped on an empty screen.
class CarPublishSuccessScreen extends StatelessWidget {
  const CarPublishSuccessScreen({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
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
                'Anúncio publicado',
                style: AppTextStyles.headingMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${car.title} já aparece nas pesquisas de clientes em '
                '${car.location.label}.',
                style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                RentFormatters.perDay(car.pricing.pricePerDay),
                style: AppTextStyles.headingSm.copyWith(
                  color: RentCarColors.primary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => RentCarTheme.wrap(
                        MyCarManageScreen(carId: car.id, justPublished: true),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.event_available_rounded, size: 18),
                  label: const Text('Gerar disponibilidade'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  child: const Text('Concluir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
