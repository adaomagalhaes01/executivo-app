import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_sheet.dart';
import '../providers/rentacar_owner_provider.dart';

/// Lets the owner block or release a date range on one of their vehicles.
///
/// Resolves to `true` when something changed, so the caller knows whether to
/// reload its data.
class CarAvailabilitySheet extends StatefulWidget {
  const CarAvailabilitySheet({super.key, required this.car});

  final Car car;

  static Future<bool?> show(BuildContext context, {required Car car}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CarAvailabilitySheet(car: car),
    );
  }

  @override
  State<CarAvailabilitySheet> createState() => _CarAvailabilitySheetState();
}

class _CarAvailabilitySheetState extends State<CarAvailabilitySheet> {
  DateTimeRange? _selected;

  Future<void> _apply() async {
    final range = _selected;
    if (range == null) return;
    final provider = context.read<RentCarOwnerProvider>();
    final navigator = Navigator.of(context);

    final ok = await provider.blockDates(
      widget.car.id,
      start: range.start,
      end: range.end,
    );
    if (!ok) return;
    navigator.pop(true);
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDateRange: _selected,
      helpText: 'Datas a bloquear',
      saveText: 'Bloquear',
    );
    if (picked == null || !mounted) return;
    setState(() => _selected = picked);
  }

  Future<void> _unblock(int index) async {
    final provider = context.read<RentCarOwnerProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final period = widget.car.availability.blockedPeriods[index];
    await provider.unblockDate(widget.car.id, period.start);
    messenger.showSnackBar(
      const SnackBar(content: Text('Data libertada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocked = widget.car.availability.blockedPeriods;

    return ExecutiveSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disponibilidade', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.car.title,
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_busy_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _selected == null
                            ? 'Escolher datas para bloquear'
                            : RentFormatters.compactDateRange(
                                _selected!.start,
                                _selected!.end,
                              ),
                        style: AppTextStyles.bodyLg,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selected == null ? null : _apply,
              icon: const Icon(Icons.block_rounded, size: 18),
              label: const Text('Bloquear período'),
            ),
          ),
          if (blocked.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl),
            Text('Períodos bloqueados', style: AppTextStyles.titleSm),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var index = 0; index < blocked.length; index++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(
                        Icons.event_busy_rounded,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      title: Text(
                        RentFormatters.compactDateRange(
                          blocked[index].start,
                          blocked[index].end,
                        ),
                        style: AppTextStyles.bodyMd,
                      ),
                      trailing: IconButton(
                        tooltip: 'Libertar',
                        onPressed: () => _unblock(index),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}