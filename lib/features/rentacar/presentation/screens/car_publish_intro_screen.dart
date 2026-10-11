import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/rentacar_owner_provider.dart';
import 'car_publish_screen.dart';

/// Explains what publishing involves before opening the wizard.
///
/// The wizard is long (seven steps), so the owner gets the requirements and a
/// realistic expectation of what happens next before committing to it.
class CarPublishIntroScreen extends StatelessWidget {
  const CarPublishIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final hasDraft = context.select<RentCarOwnerProvider, bool>(
      (provider) => provider.draft.hasAnyPhoto || provider.draft.brand.isNotEmpty,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar o meu carro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: RentCarColors.primary.withAlpha(14),
                      borderRadius: AppRadius.circularCardLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 32,
                          color: RentCarColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'O seu carro rende enquanto não o usa',
                          style: AppTextStyles.titleLg.copyWith(
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Publique o anúncio em poucos minutos e receba pedidos '
                          'de clientes verificados.',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('O que precisa', style: AppTextStyles.titleMd),
                  const SizedBox(height: AppSpacing.md),
                  const _Requirement(
                    icon: Icons.photo_camera_rounded,
                    title: 'Fotografias do veículo',
                    subtitle:
                        'Mínimo 3: capa, exterior e interior. A primeira é '
                        'a capa do anúncio.',
                  ),
                  const _Requirement(
                    icon: Icons.description_rounded,
                    title: 'Documentos do veículo',
                    subtitle:
                        'Carta de condução, seguro e ficha técnica (apenas '
                        'para sua conferência).',
                  ),
                  const _Requirement(
                    icon: Icons.payments_rounded,
                    title: 'Preço por dia',
                    subtitle:
                        'Pode definir valores semanais e mensais para '
                        'alugueres mais longos.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Como funciona', style: AppTextStyles.titleMd),
                  const SizedBox(height: AppSpacing.md),
                  const _Step(
                    index: 1,
                    text: 'Preenche os dados e carrega as fotografias.',
                  ),
                  const _Step(
                    index: 2,
                    text: 'O anúncio é publicado e aparece nas pesquisas.',
                  ),
                  const _Step(
                    index: 3,
                    text: 'Recebe pedidos e aceita os que lhe convêm.',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RentCarTheme.wrap(const CarPublishScreen()),
                    ),
                  ),
                  child: Text(
                    hasDraft ? 'Continuar anúncio' : 'Começar anúncio',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: RentCarColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSm),
                Text(subtitle, style: AppTextStyles.captionSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: RentCarColors.primary.withAlpha(28),
            child: Text(
              '$index',
              style: AppTextStyles.captionSm.copyWith(
                color: RentCarColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTextStyles.bodyMd)),
        ],
      ),
    );
  }
}
