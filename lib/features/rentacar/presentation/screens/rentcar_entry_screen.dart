import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/car_search_provider.dart';
import '../providers/rentacar_owner_provider.dart';
import '../providers/rentacar_rental_provider.dart';
import '../widgets/rentcar_action_card.dart';
import 'car_publish_intro_screen.dart';
import 'car_search_screen.dart';
import 'my_cars_screen.dart';
import 'my_rentals_screen.dart';
import 'received_rentals_screen.dart';

/// Landing screen for the module — reachable from the drawer and the profile.
///
/// Keeps the two audiences separated at a glance: renting is the primary
/// action, publishing is the secondary one, and both management areas are
/// listed underneath.
class RentCarEntryScreen extends StatefulWidget {
  const RentCarEntryScreen({super.key});

  @override
  State<RentCarEntryScreen> createState() => _RentCarEntryScreenState();
}

class _RentCarEntryScreenState extends State<RentCarEntryScreen> {
  late int _vehicleCount;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final owner = context.read<RentCarOwnerProvider>();
    final rentals = context.read<RentCarRentalProvider>();
    await Future.wait([owner.loadMyCars(), rentals.loadAll()]);
    if (!mounted) return;
    setState(() => _vehicleCount = owner.myCars.length);
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RentCarTheme.wrap(screen)))
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return RentCarTheme.wrap(Builder(builder: _buildThemed));
  }

  Widget _buildThemed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final rentals = context.watch<RentCarRentalProvider>();
    final catalogue = context.watch<CarSearchProvider>().catalogue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXECUTIVO RENT A CAR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            _Hero(catalogue: catalogue, textColor: textColor),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Precisa de um carro?',
              style: AppTextStyles.titleLg.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Compare veículos verificados, escolha o local de entrega '
              'e reserve em poucos passos.',
              style: AppTextStyles.bodyMd.copyWith(color: mutedColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            RentCarActionCard(
              icon: Icons.search_rounded,
              title: 'Alugar um carro',
              subtitle: 'Pesquise por local, datas e características',
              emphasised: true,
              onTap: () => _push(context, const CarSearchScreen()),
            ),
            const SizedBox(height: AppSpacing.md),
            RentCarActionCard(
              icon: Icons.add_business_rounded,
              title: 'Publicar o meu carro',
              subtitle: 'Anuncie o veículo e receba pedidos',
              onTap: () => _push(context, const CarPublishIntroScreen()),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(text: 'Acompanhar'),
            const SizedBox(height: AppSpacing.md),
            RentCarActionCard(
              icon: Icons.directions_car_filled_rounded,
              title: 'Os meus carros',
              subtitle: 'Gerir anúncios, preços e disponibilidade',
              trailing: RentCarCountBadge(count: _vehicleCount),
              onTap: () => _push(context, const MyCarsScreen()),
            ),
            const SizedBox(height: AppSpacing.md),
            RentCarActionCard(
              icon: Icons.event_available_rounded,
              title: 'Minhas reservas',
              subtitle:
                  '${rentals.upcomingRentals.length} reserva(s) agendada(s)',
              trailing: RentCarCountBadge(
                count: rentals.upcomingRentals.length,
              ),
              onTap: () => _push(context, const MyRentalsScreen()),
            ),
            const SizedBox(height: AppSpacing.md),
            RentCarActionCard(
              icon: Icons.inbox_rounded,
              title: 'Pedidos recebidos',
              subtitle: 'Pedidos dos clientes sobre os seus carros',
              trailing: RentCarCountBadge(
                count: rentals.pendingRequests.length,
              ),
              onTap: () => _push(context, const ReceivedRentalsScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSm.copyWith(
        color: RentCarColors.primary,
        letterSpacing: 1,
      ),
    );
  }
}

/// Branded header with a real vehicle photo taken from the catalogue.
class _Hero extends StatelessWidget {
  const _Hero({required this.catalogue, required this.textColor});

  final List<Car> catalogue;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final car = catalogue.isEmpty ? null : catalogue.first;
    final imagePath = car?.coverImage?.path;

    return Container(
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadius.circularCardLg,
        color: AppColors.darkSurface,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.darkSurface,
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.textOnDarkSecondary,
                  size: 48,
                ),
              ),
            )
          else
            const ColoredBox(color: AppColors.darkSurface),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(isDark ? 190 : 170),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Conduza com confiança',
                  style: AppTextStyles.headingMd.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Veículos verificados, seguros incluídos e entrega onde '
                  'precisar.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withAlpha(215),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
