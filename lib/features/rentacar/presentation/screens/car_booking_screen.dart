import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/models/rental.dart';
import '../../../../core/models/rental_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/car_search_provider.dart';
import '../providers/rentacar_rental_provider.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/price_breakdown.dart';
import 'car_booking_confirmation_screen.dart';

/// Dates, delivery and price confirmation — the last step before requesting.
///
/// Nothing is charged here: the request goes to the owner as `pending` and only
/// becomes a reservation once they accept.
class CarBookingScreen extends StatefulWidget {
  const CarBookingScreen({super.key, required this.carId});

  final String carId;

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  Car? _car;
  DateTimeRange? _dates;
  bool _withDelivery = false;
  RentalLocation? _deliveryLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CarSearchProvider>();
      final criteria = provider.criteria;
      setState(() {
        _car = provider.carById(widget.carId);
        if (criteria.hasDates) {
          _dates = DateTimeRange(
            start: criteria.pickupDate!,
            end: criteria.returnDate!,
          );
        }
        _withDelivery = criteria.withDelivery;
      });
    });
  }

  int get _days {
    final range = _dates;
    if (range == null) return 1;
    final diff = DateTime(range.end.year, range.end.month, range.end.day)
        .difference(DateTime(range.start.year, range.start.month, range.start.day))
        .inDays;
    return diff < 1 ? 1 : diff;
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dates,
      helpText: 'Selecionar as datas da reserva',
      saveText: 'Confirmar',
    );
    if (picked == null || !mounted) return;
    setState(() => _dates = picked);
  }

  Future<void> _pickDeliveryLocation() async {
    final car = _car;
    if (car == null) return;
    final picked = await LocationPickerSheet.show(
      context,
      selected: _deliveryLocation,
    );
    if (picked == null || !mounted) return;
    setState(() => _deliveryLocation = picked);
  }

  Future<void> _submit(Car car) async {
    final start = _dates?.start ?? DateTime.now();
    final end = _dates?.end ?? start.add(const Duration(days: 1));
    final pickup = _dates == null
        ? car.location
        : (_deliveryLocation ?? car.location);

    final rental = Rental(
      id: '',
      car: car,
      pickupDate: start,
      returnDate: end,
      pickupLocation: _withDelivery ? pickup : null,
      withDelivery: _withDelivery,
      quote: car.pricing.quote(days: _days, withDelivery: _withDelivery),
      status: RentalStatus.pending,
      createdAt: DateTime.now(),
    );

    final provider = context.read<RentCarRentalProvider>();
    final created = await provider.requestBooking(rental);
    if (!mounted) return;

    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RentCarTheme.wrap(
          CarBookingConfirmationScreen(rental: created),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = _car;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar reserva'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: car == null
          ? const ExecutiveStateView.loading()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                _VehicleRow(car: car),
                const SizedBox(height: AppSpacing.xl),
                _SelectionRow(
                  icon: Icons.calendar_month_rounded,
                  title: 'Datas',
                  value: _dates == null
                      ? 'Escolher datas'
                      : '${RentFormatters.compactDateRange(_dates!.start, _dates!.end)}'
                          ' · $_days ${_days == 1 ? 'dia' : 'dias'}',
                  onTap: _pickDates,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  value: _withDelivery,
                  onChanged: (value) => setState(() {
                    _withDelivery = value;
                    if (!value) _deliveryLocation = null;
                  }),
                  title: Text('Entrega no meu local', style: AppTextStyles.bodyLg),
                  subtitle: Text(
                    'Caução e taxa de entrega incluídas no total',
                    style: AppTextStyles.captionSm,
                  ),
                  secondary: const Icon(Icons.local_shipping_rounded),
                ),
                if (_withDelivery) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _SelectionRow(
                    icon: Icons.place_rounded,
                    title: 'Morada de entrega',
                    value: _deliveryLocation?.label ?? 'Escolher morada',
                    onTap: _pickDeliveryLocation,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Text(
                      'Resumo do preço',
                      style: AppTextStyles.titleMd,
                    ),
                    const Spacer(),
                    Text(
                      car.pricing.pricePerDay ==
                              car.pricing.effectiveDailyRate(_days)
                          ? 'tarifa diária'
                          : 'tarifa semanal/mensal aplicada',
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PriceBreakdown(quote: car.pricing.quote(
                  days: _days,
                  withDelivery: _withDelivery,
                )),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Ao continuar, o pedido é enviado ao proprietário. A reserva '
                  'só fica confirmada depois da aceitação dele.',
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
      bottomNavigationBar: car == null
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
                child: Consumer<RentCarRentalProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton.icon(
                      onPressed: provider.isSubmitting || _dates == null
                          ? null
                          : () => _submit(car),
                      icon: provider.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_rounded, size: 18),
                      label: Text(
                        provider.isSubmitting
                            ? 'A enviar…'
                            : 'Solicitar reserva',
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final cover = car.coverImage;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            height: 60,
            child: cover == null
                ? Container(color: AppColors.surfaceVariant)
                : Image.asset(
                    cover.path,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(car.title, style: AppTextStyles.titleSm),
              Text(car.location.label, style: AppTextStyles.captionSm),
            ],
          ),
        ),
        Text(
          RentFormatters.kwanza(car.pricing.pricePerDay),
          style: AppTextStyles.titleSm.copyWith(color: RentCarColors.primary),
        ),
      ],
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: RentCarColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.captionSm),
                    Text(value, style: AppTextStyles.bodyLg),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
