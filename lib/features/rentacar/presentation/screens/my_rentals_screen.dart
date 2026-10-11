import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/rental.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/executive_state_view.dart';
import '../providers/rentacar_rental_provider.dart';
import '../widgets/rental_card.dart';
import 'rental_detail_screen.dart';

/// "Minhas reservas": what is coming up and what has already happened.
class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentCarRentalProvider>().loadMyRentals();
    });
  }

  Future<void> _cancel(Rental rental) async {
    final provider = context.read<RentCarRentalProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Text(
          'Tem a certeza de que quer cancelar a reserva de '
          '${rental.car.title}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Manter'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar reserva'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.cancelRental(rental.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Reserva cancelada.' : 'Não foi possível cancelar.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarRentalProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas reservas'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximas'),
              Tab(text: 'Anteriores'),
            ],
          ),
        ),
        body: _body(provider),
      ),
    );
  }

  Widget _body(RentCarRentalProvider provider) {
    if (provider.isLoading && provider.myRentals.isEmpty) {
      return const ExecutiveStateView.loading(
        message: 'A carregar as suas reservas…',
      );
    }

    return TabBarView(
      children: [
        _List(
          rentals: provider.upcomingRentals,
          emptyMessage:
              'Ainda não tem reservas agendadas. Encontre um carro e '
              'solicite uma reserva.',
          onCancel: _cancel,
        ),
        _List(
          rentals: provider.pastRentals,
          emptyMessage: 'O histórico de alugueres aparece aqui.',
          onCancel: _cancel,
        ),
      ],
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.rentals,
    required this.emptyMessage,
    required this.onCancel,
  });

  final List<Rental> rentals;
  final String emptyMessage;
  final ValueChanged<Rental> onCancel;

  @override
  Widget build(BuildContext context) {
    if (rentals.isEmpty) {
      return ExecutiveStateView.empty(
        icon: Icons.event_available_rounded,
        title: 'Nada por aqui',
        message: emptyMessage,
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<RentCarRentalProvider>().loadMyRentals,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        itemCount: rentals.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final rental = rentals[index];
          return RentalCard(
            rental: rental,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RentCarTheme.wrap(
                  RentalDetailScreen(rentalId: rental.id),
                ),
              ),
            ),
            onCancel: () => onCancel(rental),
          );
        },
      ),
    );
  }
}
