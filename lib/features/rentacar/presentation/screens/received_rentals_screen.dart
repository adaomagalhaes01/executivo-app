import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/rental_request.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/rent_formatters.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/rentacar_owner_provider.dart';
import '../providers/rentacar_rental_provider.dart';
import '../widgets/rental_card.dart';

/// "Pedidos recebidos": bookings other people requested on the user's cars.
///
/// Pending requests are actionable inline — accepting one also flips the
/// listing to "rented" so it stops appearing in search.
class ReceivedRentalsScreen extends StatefulWidget {
  const ReceivedRentalsScreen({super.key});

  @override
  State<ReceivedRentalsScreen> createState() => _ReceivedRentalsScreenState();
}

class _ReceivedRentalsScreenState extends State<ReceivedRentalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentCarRentalProvider>().loadReceivedRequests();
    });
  }

  Future<void> _answer(RentalRequest request, bool accept) async {
    final provider = context.read<RentCarRentalProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (accept) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aceitar pedido'),
          content: Text(
            'Confirmar ${request.renter.name} no ${request.rental.car.title} '
            'de ${RentFormatters.shortDate(request.rental.pickupDate)} a '
            '${RentFormatters.shortDate(request.rental.returnDate)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceitar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final ok = accept
        ? await provider.confirmRequest(request.rental.id)
        : await provider.rejectRequest(request.rental.id);

    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o pedido.')),
      );
      return;
    }
    if (!mounted) return;

    if (accept) {
      await context
          .read<RentCarOwnerProvider>()
          .markRented(request.rental.car.id, rented: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarRentalProvider>();
    final pending = provider.pendingRequests;
    final history = provider.receivedRequests
        .where((request) => !request.canBeAnswered)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos recebidos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _body(provider, pending, history),
    );
  }

  Widget _body(
    RentCarRentalProvider provider,
    List<RentalRequest> pending,
    List<RentalRequest> history,
  ) {
    if (provider.isLoading && provider.receivedRequests.isEmpty) {
      return const ExecutiveStateView.loading(
        message: 'A carregar pedidos…',
      );
    }

    if (pending.isEmpty && history.isEmpty) {
      return const ExecutiveStateView.empty(
        icon: Icons.inbox_rounded,
        title: 'Sem pedidos',
        message: 'Quando alguém solicitar um dos seus veículos, o pedido '
            'aparece aqui.',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadReceivedRequests,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          if (pending.isNotEmpty) ...[
            _Header(
              label: 'Por responder (${pending.length})',
              emphasised: true,
            ),
            for (final request in pending) ...[
              RentalRequestCard(
                request: request,
                onAccept: provider.isSubmitting
                    ? null
                    : () => _answer(request, true),
                onDecline: provider.isSubmitting
                    ? null
                    : () => _answer(request, false),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
          if (history.isNotEmpty) ...[
            _Header(label: 'Histórico (${history.length})'),
            for (final request in history) ...[
              RentalRequestCard(request: request),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.label, this.emphasised = false});

  final String label;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: emphasised ? RentCarColors.primary : AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}